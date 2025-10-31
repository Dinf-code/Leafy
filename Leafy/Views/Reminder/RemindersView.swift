//
//  RemindersView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//

import SwiftUI

struct RemindersView: View {
    @ObservedObject private var store = PlantStore.shared
    @State private var selectedFilter: ReminderFilter = .all
    @State private var snoozedReminders: Set<UUID> = []
    @State private var completedReminders: Set<UUID> = []
    
    enum ReminderFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case overdue = "Overdue"
    }
    
    var reminders: [PlantReminder] {
        let allReminders = store.plants.compactMap { plant -> PlantReminder? in
            guard let nextWatering = plant.nextWateringDate else { return nil }
            
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextWatering).day ?? 0
            let priority: ReminderPriority = daysUntil < -2 ? .critical : daysUntil < 0 ? .high : daysUntil == 0 ? .normal : .low
            
            return PlantReminder(
                id: plant.id,
                plantName: plant.commonName,
                type: .watering,
                dueDate: nextWatering,
                priority: priority,
                isCompleted: completedReminders.contains(plant.id),
                isSnoozed: snoozedReminders.contains(plant.id)
            )
        }
        
        // Filter
        let filtered: [PlantReminder]
        switch selectedFilter {
        case .all:
            filtered = allReminders
        case .today:
            filtered = allReminders.filter { Calendar.current.isDateInToday($0.dueDate) }
        case .upcoming:
            filtered = allReminders.filter {
                let days = Calendar.current.dateComponents([.day], from: Date(), to: $0.dueDate).day ?? 0
                return days > 0
            }
        case .overdue:
            filtered = allReminders.filter {
                $0.dueDate < Date() && !Calendar.current.isDateInToday($0.dueDate)
            }
        }
        
        return filtered.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filter Tabs
                if !store.plants.isEmpty {
                    FilterTabBar(selectedFilter: $selectedFilter)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                if reminders.isEmpty {
                    EmptyRemindersState(filter: selectedFilter)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(reminders) { reminder in
                                ReminderCard(
                                    reminder: reminder,
                                    onComplete: { handleComplete(reminder) },
                                    onSnooze: { handleSnooze(reminder) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Reminders")
    }
    
    private func handleComplete(_ reminder: PlantReminder) {
        completedReminders.insert(reminder.id)
        
        // Update plant's next watering date
        if let index = store.plants.firstIndex(where: { $0.id == reminder.id }) {
            var updatedPlant = store.plants[index]
            let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            updatedPlant.nextWateringDate = nextDate
            store.plants[index] = updatedPlant
            
            // Reschedule notification
            ReminderManager.shared.scheduleReminder(for: updatedPlant, on: nextDate)
        }
        
        // Remove from completed after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completedReminders.remove(reminder.id)
        }
    }
    
    private func handleSnooze(_ reminder: PlantReminder) {
        snoozedReminders.insert(reminder.id)
        
        // Update to tomorrow
        if let index = store.plants.firstIndex(where: { $0.id == reminder.id }) {
            var updatedPlant = store.plants[index]
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            updatedPlant.nextWateringDate = tomorrow
            store.plants[index] = updatedPlant
            
            // Reschedule notification
            ReminderManager.shared.scheduleReminder(for: updatedPlant, on: tomorrow)
        }
        
        // Remove from snoozed list after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            snoozedReminders.remove(reminder.id)
        }
    }
}

// MARK: - Filter Tab Bar
struct FilterTabBar: View {
    @Binding var selectedFilter: RemindersView.ReminderFilter
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(RemindersView.ReminderFilter.allCases, id: \.self) { filter in
                Button(action: { selectedFilter = filter }) {
                    Text(filter.rawValue)
                        .font(.subheadline.bold())
                        .foregroundColor(selectedFilter == filter ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedFilter == filter ?
                            LeafyTheme.Colors.accent :
                            Color.clear
                        )
                }
            }
        }
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Reminder Card
struct ReminderCard: View {
    let reminder: PlantReminder
    let onComplete: () -> Void
    let onSnooze: () -> Void
    
    @State private var isExpanded = false
    
    var daysUntilText: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: reminder.dueDate).day ?? 0
        if Calendar.current.isDateInToday(reminder.dueDate) {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days < 0 {
            return "Overdue by \(abs(days)) days"
        } else {
            return "In \(days) days"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            HStack(spacing: 16) {
                // Icon
                Image(systemName: reminder.type.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(reminder.priority.color)
                    .clipShape(Circle())
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.plantName)
                        .font(.headline)
                        .foregroundColor(LeafyTheme.Colors.text)
                    
                    Text(reminder.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text(daysUntilText)
                            .font(.caption.bold())
                    }
                    .foregroundColor(reminder.priority.color)
                }
                
                Spacer()
                
                // Expand button
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Expanded Actions
            if isExpanded {
                Divider()
                
                HStack(spacing: 12) {
                    // Snooze Button
                    Button(action: onSnooze) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Snooze")
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Complete Button
                    Button(action: onComplete) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete")
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(LeafyTheme.Colors.success.opacity(0.2))
                        .foregroundColor(LeafyTheme.Colors.success)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(reminder.priority.color.opacity(0.3), lineWidth: 1)
        )
        .opacity(reminder.isCompleted || reminder.isSnoozed ? 0.5 : 1.0)
    }
}

// MARK: - Empty State
struct EmptyRemindersState: View {
    let filter: RemindersView.ReminderFilter
    
    var message: String {
        switch filter {
        case .all: return "No reminders yet"
        case .today: return "No reminders for today"
        case .upcoming: return "No upcoming reminders"
        case .overdue: return "No overdue reminders"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(LeafyTheme.Colors.accent.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(LeafyTheme.Colors.text)
            
            Text("Add plants to see watering and care reminders here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Models
struct PlantReminder: Identifiable {
    let id: UUID
    let plantName: String
    let type: ReminderType
    let dueDate: Date
    let priority: ReminderPriority
    var isCompleted: Bool
    var isSnoozed: Bool
    
    enum ReminderType: String {
        case watering = "Watering"
        case fertilizing = "Fertilizing"
        case repotting = "Re-potting"
        
        var icon: String {
            switch self {
            case .watering: return "drop.fill"
            case .fertilizing: return "leaf.fill"
            case .repotting: return "arrow.up.bin.fill"
            }
        }
    }
}

enum ReminderPriority: Int {
    case low = 1
    case normal = 2
    case high = 3
    case critical = 4
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .normal: return LeafyTheme.Colors.accent
        case .high: return .orange
        case .critical: return .red
        }
    }
}

#Preview {
    NavigationStack {
        RemindersView()
    }
}
