//
//  PlantService.swift
//  Leafy
//
//  Created by Dinachi on 2025-11-04.
//

import UIKit
import Foundation

final class PlantService {
    enum ServiceError: Error {
        case missingAPIKey
        case noImageData
        case badURL
        case invalidResponse(status: Int)
        case decodingError(Error)
        case noResult
    }

    func identify(image: UIImage) async throws -> Plant {
        // 1) Validate key
        guard !Secrets.plantNet.isEmpty else { throw ServiceError.missingAPIKey }

        // 2) JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ServiceError.noImageData
        }

        // 3) Endpoint
        let project = "all"
        let endpoint = "https://my-api.plantnet.org/v2/identify/\(project)?api-key=\(Secrets.plantNet)"
        guard let url = URL(string: endpoint) else { throw ServiceError.badURL }

        // 4) Multipart body
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        func appendFile(_ name: String, filename: String, mime: String, data: Data) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }

        appendField("organs", "leaf")
        appendFile("images", filename: "plant.jpg", mime: "image/jpeg", data: imageData)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // 5) Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1

        print("🌿 [PlantService] HTTP Status:", status)
        print("🌿 [PlantService] Raw JSON:\n", String(data: data, encoding: .utf8) ?? "No body")

        guard status == 200 else { throw ServiceError.invalidResponse(status: status) }

        // 6) Decode → map to Plant
        do {
            let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
            guard let first = decoded.results.first else { throw ServiceError.noResult }

            let imageURL = first.images?.compactMap { $0.bestURL }.first
            print("✅ Extracted Image URL:", imageURL ?? "nil")

            // ✅ Return both remote & local image
            return Plant(
                commonName: first.species.commonNames?.first ?? "Unknown",
                scientificName: first.species.scientificNameWithoutAuthor,
                confidence: first.score,
                imageURL: imageURL,
                imageData: imageData
            )
        } catch {
            throw ServiceError.decodingError(error)
        }
    }
}

// MARK: - Response Models
extension PlantService {
    struct APIResponse: Decodable {
        let results: [ResultItem]
    }

    struct ResultItem: Decodable {
        let score: Double
        let species: Species
        let images: [ImageInfo]?
    }

    struct Species: Decodable {
        let scientificNameWithoutAuthor: String
        let commonNames: [String]?
    }

    struct ImageInfo: Decodable {
        let bestURL: String?

        private enum CodingKeys: String, CodingKey {
            case url
            case imageUrl
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)

            // Try plain string
            if let direct = try c.decodeIfPresent(String.self, forKey: .url) {
                self.bestURL = direct
                return
            }
            if let direct2 = try c.decodeIfPresent(String.self, forKey: .imageUrl) {
                self.bestURL = direct2
                return
            }

            // Try nested dictionary
            if let nested = try? c.decode([String:String].self, forKey: .url) {
                self.bestURL = nested["o"] ?? nested["m"] ?? nested.values.first
                return
            }
            if let nested2 = try? c.decode([String:String].self, forKey: .imageUrl) {
                self.bestURL = nested2["o"] ?? nested2["m"] ?? nested2.values.first
                return
            }

            self.bestURL = nil
        }
    }
}
