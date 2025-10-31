//
//  CalendarView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject private var store = PlantStore.shared
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Month/Year Header
                    HStack {
                        Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                            .font(.title2.bold())
                            .foregroundColor(LeafyTheme.Colors.text)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: { changeMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(LeafyTheme.Colors.accent)
                            }
                            
                            Button(action: { changeMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(LeafyTheme.Colors.accent)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Calendar Grid
                    CalendarGridView(selectedDate: $selectedDate)
                        .padding(.horizontal)
                    
                    // Today's Tasks Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Care")
                            .font(.headline)
                            .foregroundColor(LeafyTheme.Colors.text)
                            .padding(.horizontal)
                        
                        if store.plants.isEmpty {
                            EmptyCalendarState()
                        } else {
                            ForEach(upcomingTasks, id: \.id) { task in
                                TaskCard(task: task)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Calendar")
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private var upcomingTasks: [CareTask] {
        // Generate mock tasks from plants
        store.plants.compactMap { plant in
            guard let nextWatering = plant.nextWateringDate else { return nil }
            return CareTask(
                id: plant.id,
                plantName: plant.commonName,
                taskType: .watering,
                dueDate: nextWatering,
                isCompleted: false
            )
        }
    }
}

// MARK: - Calendar Grid
struct CalendarGridView: View {
    @Binding var selectedDate: Date
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, selectedDate: $selectedDate)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var dates: [Date?] = []
        let days = Calendar.current.dateComponents([.day], from: monthFirstWeek.start, to: monthInterval.end).day ?? 0
        
        for day in 0...days {
            if let date = Calendar.current.date(byAdding: .day, value: day, to: monthFirstWeek.start) {
                if Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                    dates.append(date)
                } else if dates.isEmpty || dates.last != nil {
                    dates.append(nil)
                }
            }
        }
        
        return dates
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        Button(action: { selectedDate = date }) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline)
                    .foregroundColor(isToday ? .white : LeafyTheme.Colors.text)
                
                // Indicator dot for tasks
                Circle()
                    .fill(LeafyTheme.Colors.accent)
                    .frame(width: 4, height: 4)
                    .opacity(hasTaskOnDate(date) ? 1 : 0)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                isToday ? LeafyTheme.Colors.accent :
                isSelected ? LeafyTheme.Colors.accent.opacity(0.3) :
                Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func hasTaskOnDate(_ date: Date) -> Bool {
        // Check if any plant has a task on this date
        PlantStore.shared.plants.contains { plant in
            guard let nextWatering = plant.nextWateringDate else { return false }
            return Calendar.current.isDate(nextWatering, inSameDayAs: date)
        }
    }
}

// MARK: - Task Card
struct TaskCard: View {
    let task: CareTask
    @State private var isCompleted: Bool
    
    init(task: CareTask) {
        self.task = task
        _isCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Task icon
            Image(systemName: task.taskType.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(task.taskType.color)
                .clipShape(Circle())
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.plantName)
                    .font(.headline)
                    .foregroundColor(LeafyTheme.Colors.text)
                
                Text(task.taskType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Checkbox
            Button(action: { isCompleted.toggle() }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? LeafyTheme.Colors.success : .secondary)
            }
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}

// MARK: - Empty State
struct EmptyCalendarState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(LeafyTheme.Colors.accent.opacity(0.5))
            
            Text("No care tasks yet")
                .font(.headline)
                .foregroundColor(LeafyTheme.Colors.text)
            
            Text("Add plants to see watering and care reminders here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Supporting Models
struct CareTask: Identifiable {
    let id: UUID
    let plantName: String
    let taskType: TaskType
    let dueDate: Date
    var isCompleted: Bool
    
    enum TaskType: String {
        case watering = "Water"
        case fertilizing = "Fertilize"
        case repotting = "Re-pot"
        case pruning = "Prune"
        
        var icon: String {
            switch self {
            case .watering: return "drop.fill"
            case .fertilizing: return "leaf.fill"
            case .repotting: return "arrow.up.bin.fill"
            case .pruning: return "scissors"
            }
        }
        
        var color: Color {
            switch self {
            case .watering: return .blue
            case .fertilizing: return LeafyTheme.Colors.accent
            case .repotting: return .orange
            case .pruning: return .purple
            }
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
}
