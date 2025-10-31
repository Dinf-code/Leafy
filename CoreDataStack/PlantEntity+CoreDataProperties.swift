//
//  PlantEntity+CoreDataProperties.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//
//

import Foundation
import CoreData

extension PlantEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlantEntity> {
        return NSFetchRequest<PlantEntity>(entityName: "PlantEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var commonName: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var confidence: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var nextWateringDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var lastModified: Date?
    @NSManaged public var healthStatus: String?
    @NSManaged public var isSynced: Bool
    @NSManaged public var cloudId: String?
    @NSManaged public var journalEntries: NSSet?
}

// MARK: Generated accessors for journalEntries
extension PlantEntity {
    @objc(addJournalEntriesObject:)
    @NSManaged public func addToJournalEntries(_ value: JournalEntryEntity)

    @objc(removeJournalEntriesObject:)
    @NSManaged public func removeFromJournalEntries(_ value: JournalEntryEntity)

    @objc(addJournalEntries:)
    @NSManaged public func addToJournalEntries(_ values: NSSet)

    @objc(removeJournalEntries:)
    @NSManaged public func removeFromJournalEntries(_ values: NSSet)
}

extension PlantEntity: Identifiable {}
