//
//  JournalEntryEntity+CoreDataProperties.swift
//  Leafy
//
//  Created by Emeka prince amobi on 2025-11-06.
//
//
import Foundation
import CoreData

extension JournalEntryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntryEntity> {
        return NSFetchRequest<JournalEntryEntity>(entityName: "JournalEntryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var note: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var date: Date?
    @NSManaged public var plant: PlantEntity?
}

extension JournalEntryEntity: Identifiable {}
