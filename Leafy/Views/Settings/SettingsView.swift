//
//  SettingsView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationManager = LocationManager.shared
    @State private var showingNotificationPreferences = false
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var temperatureUnit: TemperatureUnit = .celsius
    
    enum TemperatureUnit: String, CaseIterable {
        case celsius = "Celsius (°C)"
        case fahrenheit = "Fahrenheit (°F)"
    }
    
    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    ProfileHeaderSection(onEditTap: { showingEditProfile = true })
                        .padding(.top)
                    
                    // Account Section
                    SettingsSection(title: "Account", icon: "person.fill") {
                        SettingsRow(
                            icon: "pencil.circle.fill",
                            title: "Edit Profile",
                            iconColor: LeafyTheme.Colors.accent
                        ) {
                            showingEditProfile = true
                        }
                        
                        SettingsRow(
                            icon: "lock.fill",
                            title: "Change Password",
                            iconColor: .blue
                        ) {
                            // TODO: Implement
                        }
                        
                        SettingsRow(
                            icon: "crown.fill",
                            title: "Subscription",
                            iconColor: .orange,
                            badge: "Pro"
                        ) {
                            // TODO: Implement
                        }
                    }
                    
                    // Preferences Section
                    SettingsSection(title: "Preferences", icon: "slider.horizontal.3") {
                        SettingsToggleRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            iconColor: .red,
                            isOn: $notificationsEnabled
                        )
                        
                        SettingsRow(
                            icon: "bell.badge.fill",
                            title: "Notification Settings",
                            iconColor: .purple
                        ) {
                            showingNotificationPreferences = true
                        }
                        
                        SettingsToggleRow(
                            icon: "moon.fill",
                            title: "Dark Mode",
                            iconColor: .indigo,
                            isOn: $isDarkMode
                        )
                        
                        SettingsPickerRow(
                            icon: "thermometer",
                            title: "Temperature Unit",
                            iconColor: .orange,
                            selection: $temperatureUnit
                        )
                    }
                    
                    // Support Section
                    SettingsSection(title: "Support", icon: "questionmark.circle.fill") {
                        SettingsRow(
                            icon: "book.fill",
                            title: "Help & FAQ",
                            iconColor: .green
                        ) {
                            // TODO: Open help
                        }
                        
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Contact Us",
                            iconColor: .blue
                        ) {
                            // TODO: Open contact
                        }
                        
                        SettingsRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            iconColor: .gray
                        ) {
                            // TODO: Open privacy policy
                        }
                    }
                    
                    // App Info
                    VStack(spacing: 8) {
                        Text("Leafy")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    // Logout Button
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                            Text("Logout")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingNotificationPreferences) {
            NavigationStack {
                NotificationPreferencesView()
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            NavigationStack {
                EditProfileView()
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    private func handleLogout() {
        appState.isAuthenticated = false
        appState.isGuest = false
    }
}

// MARK: - Profile Header Section
struct ProfileHeaderSection: View {
    let onEditTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [LeafyTheme.Colors.accent, LeafyTheme.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                
                // Edit badge
                Button(action: onEditTap) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(LeafyTheme.Colors.accent)
                        .background(
                            Circle()
                                .fill(LeafyTheme.Colors.card)
                                .frame(width: 32, height: 32)
                        )
                }
            }
            
            VStack(spacing: 4) {
                Text("Plant Lover")
                    .font(.title2.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                
                Text("plantlover@leafy.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(LeafyTheme.Colors.accent)
                Text(title)
                    .font(.headline)
                    .foregroundColor(LeafyTheme.Colors.text)
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(LeafyTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(iconColor)
                    .clipShape(Circle())
                
                Text(title)
                    .foregroundColor(LeafyTheme.Colors.text)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(iconColor)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        
        if badge == nil {
            Divider()
                .padding(.leading, 64)
        }
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(iconColor)
                .clipShape(Circle())
            
            Text(title)
                .foregroundColor(LeafyTheme.Colors.text)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(LeafyTheme.Colors.accent)
        }
        .padding()
        
        Divider()
            .padding(.leading, 64)
    }
}

// MARK: - Settings Picker Row
struct SettingsPickerRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    @Binding var selection: SettingsView.TemperatureUnit
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(iconColor)
                .clipShape(Circle())
            
            Text(title)
                .foregroundColor(LeafyTheme.Colors.text)
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(SettingsView.TemperatureUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue.split(separator: " ").first ?? "")
                        .tag(unit)
                }
            }
            .pickerStyle(.menu)
            .tint(LeafyTheme.Colors.accent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
