//
//  PlantStore.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import Foundation
import Combine
import CoreData

final class PlantStore: ObservableObject {
    static let shared = PlantStore()
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var plants: [Plant] = []
    
    private init() {
        // Subscribe to CoreData changes and convert to Plant models
        coreDataManager.$plants
            .map { entities in
                entities.map { $0.toPlant() }
            }
            .assign(to: &$plants)
        
        // Initial load
        load()
    }
    
    // MARK: - Public Methods
    func add(_ plant: Plant) {
        // Convert Plant to CoreData entity and save
        _ = coreDataManager.addPlant(
            commonName: plant.commonName,
            scientificName: plant.scientificName,
            confidence: plant.confidence,
            imageURL: plant.imageURL,
            nextWateringDate: plant.nextWateringDate
        )
        // No need to call load() - the publisher will update automatically
    }
    
    func remove(_ plant: Plant) {
        // Find the CoreData entity and delete it
        guard let plantEntity = findPlantEntity(by: plant.id) else {
            print("❌ Plant not found in CoreData")
            return
        }
        
        coreDataManager.deletePlant(plantEntity)
        // No need to call load() - the publisher will update automatically
    }
    
    func update(_ plant: Plant) {
        // Find the CoreData entity and update it
        guard let plantEntity = findPlantEntity(by: plant.id) else {
            print("❌ Plant not found in CoreData")
            return
        }
        
        plantEntity.commonName = plant.commonName
        plantEntity.scientificName = plant.scientificName
        plantEntity.confidence = plant.confidence ?? 0
        plantEntity.imageURL = plant.imageURL
        plantEntity.nextWateringDate = plant.nextWateringDate
        
        coreDataManager.updatePlant(plantEntity)
        // No need to call load() - the publisher will update automatically
    }
    
    // MARK: - Private Methods
    private func findPlantEntity(by id: UUID) -> PlantEntity? {
        return coreDataManager.plants.first { $0.id == id }
    }
    
    private func load() {
        coreDataManager.fetchPlants()
        
        // Perform initial sync on first launch
        if UserDefaults.standard.bool(forKey: "hasPerformedInitialSync") == false {
            Task {
                await SyncManager.shared.performFullSync()
                UserDefaults.standard.set(true, forKey: "hasPerformedInitialSync")
            }
        }
    }
    
    // MARK: - Migration from Old UserDefaults (if needed)
    func migrateFromUserDefaults() {
        let key = "savedPlants"
        guard let data = UserDefaults.standard.data(forKey: key),
              let savedPlants = try? JSONDecoder().decode([Plant].self, from: data),
              !savedPlants.isEmpty else {
            print("ℹ️ No old UserDefaults plants to migrate")
            return
        }
        
        print("🔄 Migrating \(savedPlants.count) plants from UserDefaults to CoreData...")
        
        for plant in savedPlants {
            _ = coreDataManager.addPlant(
                commonName: plant.commonName,
                scientificName: plant.scientificName,
                confidence: plant.confidence,
                imageURL: plant.imageURL,
                nextWateringDate: plant.nextWateringDate
            )
        }
        
        // Clear old data
        UserDefaults.standard.removeObject(forKey: key)
        print("✅ Migration complete!")
    }
}

