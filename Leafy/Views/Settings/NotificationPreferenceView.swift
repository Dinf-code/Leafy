//
//  NotificationPreferenceView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu

import SwiftUI

struct NotificationPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var enableAllNotifications = true
    @State private var selectedFrequency: NotificationFrequency = .daily
    
    // Alert toggles
    @State private var wateringAlerts = true
    @State private var fertilizingAlerts = true
    @State private var lightAlerts = false
    @State private var pottingAlerts = true
    @State private var advancedAlerts = false
    
    @State private var showingSavedAlert = false
    
    enum NotificationFrequency: String, CaseIterable {
        case daily = "Daily"
        case everyThreeDays = "Every 3 Days"
        case weekly = "Weekly"
        
        var icon: String {
            switch self {
            case .daily: return "calendar"
            case .everyThreeDays: return "calendar.badge.clock"
            case .weekly: return "calendar.circle"
            }
        }
    }
    
    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 50))
                            .foregroundColor(LeafyTheme.Colors.accent)
                        
                        Text("Notification Settings")
                            .font(.title2.bold())
                            .foregroundColor(LeafyTheme.Colors.text)
                        
                        Text("Customize your plant care reminders")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Master Toggle
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable All Notifications")
                                    .font(.headline)
                                    .foregroundColor(LeafyTheme.Colors.text)
                                
                                Text("Turn off to disable all alerts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $enableAllNotifications)
                                .labelsHidden()
                                .tint(LeafyTheme.Colors.accent)
                        }
                        .padding()
                    }
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Frequency Selector
                    if enableAllNotifications {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reminder Frequency")
                                .font(.headline)
                                .foregroundColor(LeafyTheme.Colors.text)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ForEach(NotificationFrequency.allCases, id: \.self) { frequency in
                                    FrequencyButton(
                                        frequency: frequency,
                                        isSelected: selectedFrequency == frequency
                                    ) {
                                        selectedFrequency = frequency
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Alert Types
                    if enableAllNotifications {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Alert Types")
                                .font(.headline)
                                .foregroundColor(LeafyTheme.Colors.text)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                AlertToggleRow(
                                    icon: "drop.fill",
                                    title: "Watering Reminders",
                                    description: "Get notified when plants need water",
                                    iconColor: .blue,
                                    isOn: $wateringAlerts
                                )
                                
                                AlertToggleRow(
                                    icon: "leaf.fill",
                                    title: "Fertilizing Reminders",
                                    description: "Alerts for fertilization schedule",
                                    iconColor: LeafyTheme.Colors.accent,
                                    isOn: $fertilizingAlerts
                                )
                                
                                AlertToggleRow(
                                    icon: "sun.max.fill",
                                    title: "Light Adjustments",
                                    description: "Sunlight and positioning tips",
                                    iconColor: .orange,
                                    isOn: $lightAlerts
                                )
                                
                                AlertToggleRow(
                                    icon: "arrow.up.bin.fill",
                                    title: "Re-potting Reminders",
                                    description: "When it's time to re-pot",
                                    iconColor: .brown,
                                    isOn: $pottingAlerts,
                                    showDivider: false
                                )
                            }
                            .background(LeafyTheme.Colors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                        
                        // Advanced Alerts (Future Feature)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Advanced Alerts")
                                    .font(.headline)
                                    .foregroundColor(LeafyTheme.Colors.text)
                                
                                Text("COMING SOON")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(LeafyTheme.Colors.accent)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                AlertToggleRow(
                                    icon: "brain.head.profile",
                                    title: "AI Health Insights",
                                    description: "Smart plant health monitoring",
                                    iconColor: .purple,
                                    isOn: .constant(false),
                                    showDivider: false
                                )
                                .opacity(0.5)
                            }
                            .background(LeafyTheme.Colors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    // Save Button
                    Button(action: handleSave) {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LeafyTheme.primaryGradient)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(LeafyTheme.Colors.accent)
            }
        }
        .alert("Saved!", isPresented: $showingSavedAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your notification preferences have been updated.")
        }
    }
    
    private func handleSave() {
        // Save preferences to UserDefaults
        UserDefaults.standard.set(enableAllNotifications, forKey: "enableAllNotifications")
        UserDefaults.standard.set(selectedFrequency.rawValue, forKey: "notificationFrequency")
        UserDefaults.standard.set(wateringAlerts, forKey: "wateringAlerts")
        UserDefaults.standard.set(fertilizingAlerts, forKey: "fertilizingAlerts")
        UserDefaults.standard.set(lightAlerts, forKey: "lightAlerts")
        UserDefaults.standard.set(pottingAlerts, forKey: "pottingAlerts")
        
        showingSavedAlert = true
    }
}

// MARK: - Frequency Button
struct FrequencyButton: View {
    let frequency: NotificationPreferencesView.NotificationFrequency
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: frequency.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : LeafyTheme.Colors.accent)
                
                Text(frequency.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : LeafyTheme.Colors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isSelected ?
                LeafyTheme.Colors.accent :
                LeafyTheme.Colors.card
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? LeafyTheme.Colors.accent : LeafyTheme.Colors.accent.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

// MARK: - Alert Toggle Row
struct AlertToggleRow: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    @Binding var isOn: Bool
    var showDivider: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(iconColor)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(LeafyTheme.Colors.text)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(LeafyTheme.Colors.accent)
            }
            .padding()
            
            if showDivider {
                Divider()
                    .padding(.leading, 72)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationPreferencesView()
    }
}
