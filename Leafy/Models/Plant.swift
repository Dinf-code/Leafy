//
//  Plant.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//
import Foundation

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    var commonName: String
    var scientificName: String
    var confidence: Double?
    var imageURL: String?
    var imageData: Data?            // ✅ NEW — stores the captured photo
    var nextWateringDate: Date?
    
    // MARK: - Computed Health Status
    var healthStatus: HealthStatus {
        if let confidence = confidence {
            switch confidence {
            case let x where x >= 0.8: return .healthy
            case let x where x >= 0.5: return .warning
            default: return .critical
            }
        }
        return .warning
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        commonName: String,
        scientificName: String,
        confidence: Double? = nil,
        imageURL: String? = nil,
        imageData: Data? = nil,
        nextWateringDate: Date? = nil
    ) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.confidence = confidence
        self.imageURL = imageURL
        self.imageData = imageData
        self.nextWateringDate = nextWateringDate
    }
    
    // MARK: - Equatable
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        lhs.id == rhs.id
    }
}
