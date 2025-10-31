//
//  PlantDetailView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI

struct RegisteredPlantDetailView: View {
    @ObservedObject private var store = PlantStore.shared
    private let locationManager = LocationManager.shared
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let plant: Plant
    @State private var selectedTab: DetailTab = .care
    @State private var weatherInfo: String?
    @State private var alertText: String?
    @State private var showSaveToast = false // ✅ New toast state

    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerImage
                    if let alertText = alertText {
                        alertCard(text: alertText)
                    }
                    adaptiveSchedule
                    tabSwitcher
                    tabContent
                    saveButton
                }
                .padding(.bottom, 24)
            }

            // ✅ Toast overlay
            if showSaveToast {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Plant saved to My Garden!")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.green.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showSaveToast)
            }
        }
        .navigationTitle(plant.commonName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadWeatherAndAlerts() }
    }

    // MARK: - Header Image
    private var headerImage: some View {
        ZStack(alignment: .bottomTrailing) {
            if let urlStr = plant.imageURL {
                if urlStr.hasPrefix("file://") {
                    if let url = URL(string: urlStr),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 280)
                            .clipped()
                    } else {
                        placeholderView
                    }
                } else if let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 280)
                                .clipped()
                        case .failure, .empty:
                            placeholderView
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 4) {
                Text(plant.commonName)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(plant.scientificName)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(12)
        }
        .padding(.horizontal)
        .shadow(radius: 8)
    }

    private var placeholderView: some View {
        ZStack {
            LeafyTheme.Colors.accent.opacity(0.2)
            VStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(LeafyTheme.Colors.accent.opacity(0.5))
                Text("No image")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 280)
    }

    // MARK: - Alert Card
    private func alertCard(text: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    // MARK: - Tab Switcher
    private var tabSwitcher: some View {
        HStack {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(selectedTab == tab ? .bold : .regular))
                        .foregroundColor(selectedTab == tab ? LeafyTheme.Colors.accent : .gray)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selectedTab == tab ? LeafyTheme.Colors.accent.opacity(0.1) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Tab Content
    private var tabContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch selectedTab {
            case .care:
                Text("General Care Tips")
                    .font(.headline)
                    .padding(.bottom, 4)
                Text("Water regularly, keep soil moist, and provide partial sunlight for optimal growth.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case .schedule:
                Text("Watering Schedule")
                    .font(.headline)
                    .padding(.bottom, 4)
                Text("Next watering date: \(formattedDate(plant.nextWateringDate))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            case .journal:
                Text("Plant Journal")
                    .font(.headline)
                    .padding(.bottom, 4)
                Text("Record growth progress, health observations, and notes about this plant.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Not set" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Adaptive Schedule
    private var adaptiveSchedule: some View {
        if let weatherInfo = weatherInfo {
            return AnyView(
                Text("🌤️ \(weatherInfo)")
                    .font(.subheadline)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(LeafyTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    // MARK: - Save Button (✅ Fixed)
    private var saveButton: some View {
        Button {
            store.add(plant)

            // ✅ Trigger save toast and then navigate to Dashboard
            withAnimation {
                showSaveToast = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSaveToast = false
                }
                appState.currentTab = .dashboard
                dismiss()
            }

        } label: {
            Text("Save to My Garden")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LeafyTheme.primaryGradient)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Helper
    private func loadWeatherAndAlerts() {
        locationManager.requestWhenInUse()
        alertText = plant.confidence ?? 1.0 < 0.6 ? "Low identification confidence" : nil
        weatherInfo = "Sunny, 20°C — Watering might be needed tomorrow"
    }

    enum DetailTab: String, CaseIterable {
        case care = "Care"
        case schedule = "Schedule"
        case journal = "Journal"
    }
}


#Preview {
    NavigationStack {
        RegisteredPlantDetailView(
            plant: Plant(
                commonName: "Monstera",
                scientificName: "Monstera deliciosa",
                confidence: 0.95,
                imageURL: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b"
            )
        )
        .environmentObject(AppState())
    }
}
