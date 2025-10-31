//
//  ReminderManager.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-04.
//

import Foundation
import UserNotifications

final class ReminderManager {
    static let shared = ReminderManager()
    private init() {}

    // Ask once at launch
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // New canonical method
    func scheduleReminder(for plant: Plant, on date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to care for \(plant.commonName)"
        content.body  = "Give your \(plant.commonName) some love 🌿"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(
            identifier: plant.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("❌ Reminder error:", err.localizedDescription) }
            else { print("✅ Reminder scheduled for \(plant.commonName) on \(date)") }
        }
    }

    // Back-compat helper (maps to the new API)
    func schedule(for plant: Plant, after days: Int) {
        let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date().addingTimeInterval(Double(days) * 86_400)
        scheduleReminder(for: plant, on: date)
    }

    func cancel(for plant: Plant) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [plant.id.uuidString])
    }

    // Optional: debug
    func listPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
            print("🔔 Pending:", reqs.map(\.identifier))
        }
    }
}
