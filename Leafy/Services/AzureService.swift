//
//  AzureService.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//

import Foundation
import CoreData

class AzureService {
    static let shared = AzureService()
    
    // MARK: - Azure Logic App URLs
    private let createPlantURL = "https://prod-14.canadacentral.logic.azure.com:443/workflows/a70762054bcb4803b7a05f0446582edc/triggers/When_an_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_an_HTTP_request_is_received%2Frun&sv=1.0&sig=CdH3ude_6sPAWUEFHhUP7c7NagG1Zxg_eq0Njt9BG0o"
    
    private let getPlantsURL = "https://prod-19.canadacentral.logic.azure.com:443/workflows/e464f804ddb14cd3bd1ff3753485c488/triggers/When_an_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_an_HTTP_request_is_received%2Frun&sv=1.0&sig=rhmew70MPXMqcDxWP1hQA2JoxzU3gnKH2e3of--ntHM"
    
    private let updatePlantURL = "https://prod-27.canadacentral.logic.azure.com:443/workflows/cbe1ba3cda4247b7ad3d44d7be891bbb/triggers/When_an_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_an_HTTP_request_is_received%2Frun&sv=1.0&sig=uCJqPTnSOBWBn9sVtvS4cFw-S3_7h2LsBvnuoug9UYI"
    
    private let deletePlantURL = "https://prod-15.canadacentral.logic.azure.com:443/workflows/769b2283b94449a6bc038e1e5e0096a3/triggers/When_an_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_an_HTTP_request_is_received%2Frun&sv=1.0&sig=ZefEXio3PMvp_1B6LJWrkPXuccvP4M4nmfl5TR-UpCQ"
    
    private init() {}
    
    // MARK: - Data Models
    struct AzurePlantRequest: Codable {
        let PartitionKey: String  // cloudId
        let RowKey: String        // UUID as string
        let commonName: String?
        let scientificName: String?
        let confidence: Double
        let imageURL: String?
        let nextWateringDate: String?
        let createdAt: String
        let lastModified: String
        let healthStatus: String?
    }
    
    struct AzurePlantResponse: Codable {
        let PartitionKey: String
        let RowKey: String
        let commonName: String?
        let scientificName: String?
        let confidence: Double
        let imageURL: String?
        let nextWateringDate: String?
        let createdAt: String?        // Made optional
        let lastModified: String?     // Made optional
        let healthStatus: String?
        let Timestamp: String?
    }
    
    // MARK: - CREATE Plant
    func createPlant(_ plant: PlantEntity, cloudId: String) async throws -> AzurePlantResponse {
        guard let url = URL(string: createPlantURL) else {
            throw AzureError.invalidURL
        }
        
        let plantRequest = AzurePlantRequest(
            PartitionKey: cloudId,
            RowKey: plant.id?.uuidString ?? UUID().uuidString,
            commonName: plant.commonName,
            scientificName: plant.scientificName,
            confidence: plant.confidence,
            imageURL: plant.imageURL,
            nextWateringDate: plant.nextWateringDate?.iso8601String,
            createdAt: plant.createdAt?.iso8601String ?? Date().iso8601String,
            lastModified: plant.lastModified?.iso8601String ?? Date().iso8601String,
            healthStatus: plant.healthStatus
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(plantRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AzureError.badResponse
        }
        
        print("✅ CREATE Response Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            print("❌ CREATE Error Body: \(errorBody)")
            throw AzureError.badResponse
        }
        
        return try JSONDecoder().decode(AzurePlantResponse.self, from: data)
    }
    
    // MARK: - GET Plants
    func fetchPlants(cloudId: String) async throws -> [AzurePlantResponse] {
        guard var urlComponents = URLComponents(string: getPlantsURL) else {
            throw AzureError.invalidURL
        }
        
        // Add cloudId as query parameter
        let existingQueryItems = urlComponents.queryItems ?? []
        urlComponents.queryItems = existingQueryItems + [URLQueryItem(name: "cloudId", value: cloudId)]
        
        guard let url = urlComponents.url else {
            throw AzureError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AzureError.badResponse
        }
        
        print("✅ GET Response Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            print("❌ GET Error Body: \(errorBody)")
            throw AzureError.badResponse
        }
        
        // Try to decode as array first, then as single object wrapped in array
        if let plants = try? JSONDecoder().decode([AzurePlantResponse].self, from: data) {
            return plants
        } else if let plant = try? JSONDecoder().decode(AzurePlantResponse.self, from: data) {
            return [plant]
        } else {
            return []
        }
    }
    
    // MARK: - UPDATE Plant
    func updatePlant(_ plant: PlantEntity, cloudId: String) async throws {
        guard var urlComponents = URLComponents(string: updatePlantURL) else {
            throw AzureError.invalidURL
        }
        
        let rowKey = plant.id?.uuidString ?? ""
        urlComponents.queryItems = [URLQueryItem(name: "id", value: rowKey)]
        
        guard let url = urlComponents.url else {
            throw AzureError.invalidURL
        }
        
        let plantRequest = AzurePlantRequest(
            PartitionKey: cloudId,
            RowKey: rowKey,
            commonName: plant.commonName,
            scientificName: plant.scientificName,
            confidence: plant.confidence,
            imageURL: plant.imageURL,
            nextWateringDate: plant.nextWateringDate?.iso8601String,
            createdAt: plant.createdAt?.iso8601String ?? Date().iso8601String,
            lastModified: Date().iso8601String,
            healthStatus: plant.healthStatus
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(plantRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AzureError.badResponse
        }
        
        print("✅ UPDATE Response Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            print("❌ UPDATE Error Body: \(errorBody)")
            throw AzureError.badResponse
        }
    }
    
    // MARK: - DELETE Plant
    func deletePlant(plantId: String) async throws {
        guard var urlComponents = URLComponents(string: deletePlantURL) else {
            throw AzureError.invalidURL
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "id", value: plantId)]
        
        guard let url = urlComponents.url else {
            throw AzureError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AzureError.badResponse
        }
        
        print("✅ DELETE Response Status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            print("❌ DELETE Error Body: \(errorBody)")
            throw AzureError.badResponse
        }
    }
    
    // MARK: - Error Handling
    enum AzureError: LocalizedError {
        case invalidURL
        case badResponse
        case decodingError
        case networkError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .badResponse: return "Bad response from Azure"
            case .decodingError: return "Failed to decode response"
            case .networkError: return "Network error occurred"
            }
        }
    }
}

// MARK: - Date Extension for ISO8601
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
    
    init?(iso8601String: String) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso8601String) else {
            return nil
        }
        self = date
    }
}
