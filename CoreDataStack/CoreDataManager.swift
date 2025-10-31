//
//  CoreDataManager.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//

import CoreData
import Foundation
import Combine

final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer
    @Published var plants: [PlantEntity] = []

    private init() {
        container = NSPersistentContainer(name: "LeafyDataModel")

        // Load persistent stores first
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ CoreData failed to load: \(error.localizedDescription)")
            } else {
                print("✅ CoreData loaded successfully")

                //  Fetch after container is ready
                self.container.viewContext.perform {
                    self.fetchPlants()
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - CRUD
    func fetchPlants() {
        let request = PlantEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PlantEntity.createdAt, ascending: false)]

        do {
            plants = try context.fetch(request)
            print("✅ Fetched \(plants.count) plants from CoreData")
        } catch {
            print("❌ Failed to fetch plants: \(error)")
        }
    }

    func addPlant(
        commonName: String,
        scientificName: String,
        confidence: Double?,
        imageURL: String?,
        nextWateringDate: Date?
    ) -> PlantEntity {
        let plant = PlantEntity(context: context)
        plant.id = UUID()
        plant.commonName = commonName
        plant.scientificName = scientificName
        plant.confidence = confidence ?? 0
        plant.imageURL = imageURL
        plant.nextWateringDate = nextWateringDate
        plant.createdAt = Date()
        plant.lastModified = Date()
        plant.healthStatus = "healthy"
        plant.isSynced = false

        saveContext()
        fetchPlants()
        
        // Sync to Azure in background
        Task {
            await SyncManager.shared.syncPlantToAzure(plant)
        }
        
        return plant
    }

    func updatePlant(_ plant: PlantEntity) {
        plant.lastModified = Date()
        plant.isSynced = false
        saveContext()
        fetchPlants()
        
        // Sync to Azure in background
        Task {
            await SyncManager.shared.syncPlantToAzure(plant)
        }
    }

    func deletePlant(_ plant: PlantEntity) {
        let plantId = plant.id?.uuidString ?? ""
        context.delete(plant)
        saveContext()
        fetchPlants()
        
        // Delete from Azure in background
        Task {
            await SyncManager.shared.deletePlantFromAzure(plantId)
        }
    }

    func markAsSynced(_ plant: PlantEntity, cloudId: String? = nil) {
        plant.isSynced = true
        plant.cloudId = cloudId
        saveContext()
    }

    func getUnsyncedPlants() -> [PlantEntity] {
        let request = PlantEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isSynced == NO")
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch unsynced plants: \(error)")
            return []
        }
    }

    // MARK: - Journal Entries
    func addJournalEntry(to plant: PlantEntity, note: String, imageURL: String? = nil) -> JournalEntryEntity {
        let entry = JournalEntryEntity(context: context)
        entry.id = UUID()
        entry.note = note
        entry.imageURL = imageURL
        entry.date = Date()
        entry.plant = plant

        saveContext()
        return entry
    }

    func deleteJournalEntry(_ entry: JournalEntryEntity) {
        context.delete(entry)
        saveContext()
    }

    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ CoreData context saved")
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
}

// MARK: - Conversion Extensions
extension PlantEntity {
    func toPlant() -> Plant {
        Plant(
            id: id ?? UUID(),
            commonName: commonName ?? "Unknown",
            scientificName: scientificName ?? "",
            confidence: confidence > 0 ? confidence : nil,
            imageURL: imageURL,
            nextWateringDate: nextWateringDate
        )
    }
}

extension Plant {
    func toCoreDataEntity(in context: NSManagedObjectContext) -> PlantEntity {
        let entity = PlantEntity(context: context)
        entity.id = id
        entity.commonName = commonName
        entity.scientificName = scientificName
        entity.confidence = confidence ?? 0
        entity.imageURL = imageURL
        entity.nextWateringDate = nextWateringDate
        entity.createdAt = Date()
        entity.lastModified = Date()
        entity.healthStatus = "healthy"
        entity.isSynced = false
        return entity
    }
}
