//
//  SyncManager.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//

import Foundation
import CoreData

class SyncManager {
    static let shared = SyncManager()
    
    private let azureService = AzureService.shared
    private let coreDataManager = CoreDataManager.shared
    
    // Get a unique device ID (persisted in UserDefaults)
    private var cloudId: String {
        if let existingId = UserDefaults.standard.string(forKey: "cloudId") {
            return existingId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "cloudId")
            return newId
        }
    }
    
    private init() {}
    
    // MARK: - Sync Plant to Azure (CREATE or UPDATE)
    func syncPlantToAzure(_ plant: PlantEntity) async {
        do {
            if plant.isSynced {
                // Plant already exists in Azure, UPDATE it
                print("🔄 Updating plant in Azure: \(plant.commonName ?? "Unknown")")
                try await azureService.updatePlant(plant, cloudId: cloudId)
                print("✅ Plant updated in Azure successfully")
            } else {
                // New plant, CREATE it in Azure
                print("⬆️ Creating plant in Azure: \(plant.commonName ?? "Unknown")")
                _ = try await azureService.createPlant(plant, cloudId: cloudId)
                
                // Mark as synced in CoreData
                await MainActor.run {
                    plant.isSynced = true
                    plant.cloudId = cloudId
                    coreDataManager.saveContext()
                }
                print("✅ Plant created in Azure successfully")
            }
        } catch {
            print("❌ Failed to sync plant to Azure: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Plant from Azure
    func deletePlantFromAzure(_ plantId: String) async {
        do {
            print("🗑️ Deleting plant from Azure: \(plantId)")
            try await azureService.deletePlant(plantId: plantId)
            print("✅ Plant deleted from Azure successfully")
        } catch {
            print("❌ Failed to delete plant from Azure: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Download All Plants from Azure
    func downloadPlantsFromAzure() async {
        do {
            print("⬇️ Fetching plants from Azure...")
            let azurePlants = try await azureService.fetchPlants(cloudId: cloudId)
            print("✅ Fetched \(azurePlants.count) plants from Azure")
            
            await MainActor.run {
                for azurePlant in azurePlants {
                    // Check if plant already exists locally
                    if let existingPlant = findLocalPlant(rowKey: azurePlant.RowKey) {
                        // Update existing plant
                        updateLocalPlant(existingPlant, with: azurePlant)
                    } else {
                        // Create new local plant
                        createLocalPlant(from: azurePlant)
                    }
                }
                
                coreDataManager.saveContext()
                print("✅ Synced all plants to CoreData")
            }
        } catch {
            print("❌ Failed to download plants from Azure: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper: Find Local Plant
    private func findLocalPlant(rowKey: String) -> PlantEntity? {
        let fetchRequest: NSFetchRequest<PlantEntity> = PlantEntity.fetchRequest()
        
        // Convert rowKey to UUID
        guard let uuid = UUID(uuidString: rowKey) else {
            print("❌ Invalid UUID string: \(rowKey)")
            return nil
        }
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        
        do {
            let results = try coreDataManager.context.fetch(fetchRequest)
            return results.first
        } catch {
            print("❌ Error fetching local plant: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper: Update Local Plant
    private func updateLocalPlant(_ plant: PlantEntity, with azurePlant: AzureService.AzurePlantResponse) {
        plant.commonName = azurePlant.commonName
        plant.scientificName = azurePlant.scientificName
        plant.confidence = azurePlant.confidence
        plant.imageURL = azurePlant.imageURL
        plant.healthStatus = azurePlant.healthStatus
        plant.isSynced = true
        plant.cloudId = cloudId
        
        // Parse and set nextWateringDate
        if let nextWateringString = azurePlant.nextWateringDate {
            plant.nextWateringDate = parseISO8601Date(nextWateringString)
        }
        
        // Parse and set lastModified
        if let lastModifiedString = azurePlant.lastModified {
            plant.lastModified = parseISO8601Date(lastModifiedString)
        }
    }
    
    // MARK: - Helper: Create Local Plant
    private func createLocalPlant(from azurePlant: AzureService.AzurePlantResponse) {
        let newPlant = PlantEntity(context: coreDataManager.context)
        newPlant.id = UUID(uuidString: azurePlant.RowKey) ?? UUID()
        newPlant.commonName = azurePlant.commonName
        newPlant.scientificName = azurePlant.scientificName
        newPlant.confidence = azurePlant.confidence
        newPlant.imageURL = azurePlant.imageURL
        newPlant.healthStatus = azurePlant.healthStatus
        newPlant.isSynced = true
        newPlant.cloudId = cloudId
        
        // Parse and set createdAt
        if let createdAtString = azurePlant.createdAt {
            newPlant.createdAt = parseISO8601Date(createdAtString)
        }
        
        // Parse and set nextWateringDate
        if let nextWateringString = azurePlant.nextWateringDate {
            newPlant.nextWateringDate = parseISO8601Date(nextWateringString)
        }
        
        // Parse and set lastModified
        if let lastModifiedString = azurePlant.lastModified {
            newPlant.lastModified = parseISO8601Date(lastModifiedString)
        }
    }
    
    // MARK: - Helper: Parse ISO8601 Date String
    private func parseISO8601Date(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback: try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }
    
    // MARK: - Full Sync (Upload unsync'd plants, then download)
    func performFullSync() async {
        print("🔄 Starting full sync...")
        
        // 1. Upload any unsynced plants
        await uploadUnsyncedPlants()
        
        // 2. Download all plants from Azure
        await downloadPlantsFromAzure()
        
        print("✅ Full sync complete!")
    }
    
    // MARK: - Upload Unsynced Plants
    private func uploadUnsyncedPlants() async {
        let fetchRequest: NSFetchRequest<PlantEntity> = PlantEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSynced == NO")
        
        do {
            let unsyncedPlants = try coreDataManager.context.fetch(fetchRequest)
            print("📤 Found \(unsyncedPlants.count) unsynced plants to upload")
            
            for plant in unsyncedPlants {
                await syncPlantToAzure(plant)
            }
        } catch {
            print("❌ Error fetching unsynced plants: \(error)")
        }
    }
}
