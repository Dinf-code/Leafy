//
//  PlantTabs.swift
//  Leafy
//
//  Created by Emeka prince amobi on 2025-11-06.
//

import SwiftUI

import SwiftUI

// MARK: - Care Guide Tab
struct CareGuideTab: View {
    let plant: Plant
    
    var body: some View {
        VStack(spacing: 16) {
            CareInfoCard(
                icon: "drop.fill",
                title: "Watering",
                content: "Water thoroughly when the top 1-2 inches of soil feel dry. Typically every 7-10 days, but adjust based on season and humidity.",
                iconColor: .blue
            )
            
            CareInfoCard(
                icon: "sun.max.fill",
                title: "Light",
                content: "Prefers bright, indirect light. Avoid harsh direct sunlight which may scorch leaves.",
                iconColor: .orange
            )
            
            CareInfoCard(
                icon: "thermometer",
                title: "Temperature",
                content: "Ideal range: 18–24°C (65–75°F). Keep away from cold drafts or heat vents.",
                iconColor: .red
            )
        }
        .padding()
    }
}

// MARK: - Schedule Tab
struct ScheduleTab: View {
    let plant: Plant
    let nextWateringDate: Date
    
    var body: some View {
        VStack(spacing: 16) {
            ScheduleEventCard(
                event: ScheduleEvent(type: .watering, date: nextWateringDate, isCompleted: false)
            )
            if let fertilizeDate = Calendar.current.date(byAdding: .day, value: 30, to: nextWateringDate) {
                ScheduleEventCard(
                    event: ScheduleEvent(type: .fertilizing, date: fertilizeDate, isCompleted: false)
                )
            }
        }
        .padding()
    }
}

// MARK: - Journal Tab
struct JournalTab: View {
    let plant: Plant
    @State private var journalEntries: [JournalEntry] = []
    @State private var showingAddEntry = false
    
    var body: some View {
        VStack(spacing: 16) {
            if journalEntries.isEmpty {
                Text("No Journal Entries Yet 🌱")
                    .font(.headline)
                    .padding()
            } else {
                ForEach(journalEntries) { entry in
                    JournalEntryCard(entry: entry)
                }
            }
            
            Button("Add Entry") {
                showingAddEntry = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showingAddEntry) {
            AddJournalEntryView(plant: plant) { entry in
                journalEntries.insert(entry, at: 0)
            }
        }
    }
}

// MARK: - Shared Subviews
struct CareInfoCard: View {
    let icon: String
    let title: String
    let content: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(iconColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScheduleEvent: Identifiable {
    let id = UUID()
    let type: EventType
    let date: Date
    var isCompleted: Bool
    
    enum EventType: String {
        case watering = "Watering"
        case fertilizing = "Fertilizing"
        
        var icon: String {
            switch self {
            case .watering: return "drop.fill"
            case .fertilizing: return "leaf.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .watering: return .blue
            case .fertilizing: return LeafyTheme.Colors.accent
            }
        }
    }
}

struct ScheduleEventCard: View {
    let event: ScheduleEvent
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: event.type.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(event.type.color)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(event.type.rawValue)
                    .font(.headline)
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct JournalEntry: Identifiable {
    let id = UUID()
    let date: Date
    let note: String
    let imageURL: String?
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
            Text(entry.note)
                .font(.subheadline)
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AddJournalEntryView: View {
    let plant: Plant
    let onSave: (JournalEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var note = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $note)
                    .frame(height: 200)
                    .padding()
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Journal Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = JournalEntry(date: Date(), note: note, imageURL: nil)
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(note.isEmpty)
                }
            }
        }
    }
}



