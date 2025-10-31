//
//  DashboardView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//

import SwiftUI
import CoreLocation

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var store = PlantStore.shared
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var weatherInfo: DashboardWeatherInfo?
    @State private var isLoadingWeather = false

    var body: some View {
        ZStack {
            LeafyTheme.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // HEADER
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back, Simi 👋")
                                .font(.title2.bold())
                                .foregroundColor(LeafyTheme.Colors.text)
                            Text("Your plants are thriving today!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(LeafyTheme.Colors.accent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // WEATHER WIDGET
                    if let weather = weatherInfo {
                        WeatherWidget(weather: weather)
                            .padding(.horizontal)
                    } else if isLoadingWeather {
                        WeatherLoadingCard()
                            .padding(.horizontal)
                    }

                    // TODAY'S CARE SECTION
                    TodaysCareSection(plants: store.plants)
                        .padding(.horizontal)

                    // QUICK INSIGHT OR STATS
                    if !store.plants.isEmpty {
                        HStack {
                            InsightCard(icon: "drop.fill", title: "Watering", value: "2 Due Today", color: .blue)
                            InsightCard(icon: "leaf.fill", title: "Healthy", value: "\(healthyCount()) Plants", color: .green)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Dashboard")
        .onAppear {
            loadWeather()
        }
    }

    private func healthyCount() -> Int {
        store.plants.filter { $0.healthStatus == .healthy }.count
    }
    
    // MARK: - Weather Loading
    private func loadWeather() {
        guard locationManager.lastLocation == nil else {
            fetchWeather()
            return
        }
        
        isLoadingWeather = true
        locationManager.requestWhenInUse()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            fetchWeather()
        }
    }
    
    private func fetchWeather() {
        guard let location = locationManager.lastLocation else {
            isLoadingWeather = false
            return
        }
        
        Task {
            do {
                let response = try await WeatherService().fetchWeather(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
                
                await MainActor.run {
                    weatherInfo = DashboardWeatherInfo(
                        temperature: response.main.temp,
                        humidity: response.main.humidity
                    )
                    isLoadingWeather = false
                }
            } catch {
                await MainActor.run {
                    isLoadingWeather = false
                }
            }
        }
    }
}

// MARK: - Weather Widget
struct WeatherWidget: View {
    let weather: DashboardWeatherInfo
    
    var overallAdvice: (String, String, Color) {
        // Priority: Temperature first, then humidity
        if weather.temperature > 28 {
            return ("🌡️", "Too hot! Move sensitive plants to shade", .red)
        } else if weather.temperature < 15 {
            return ("❄️", "Too cold! Bring tropical plants indoors", .blue)
        } else if weather.humidity < 30 {
            return ("💧", "Low humidity - Consider misting your plants", .orange)
        } else if weather.humidity > 70 {
            return ("🌫️", "High humidity - Ensure good airflow", .cyan)
        } else {
            return ("✨", "Perfect conditions for your plants!", LeafyTheme.Colors.success)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section: Quick overview
            HStack(spacing: 16) {
                // Icon
                Text(overallAdvice.0)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Environmental Alert")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    
                    Text(overallAdvice.1)
                        .font(.subheadline.bold())
                        .foregroundColor(LeafyTheme.Colors.text)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding()
            .background(overallAdvice.2.opacity(0.1))
            
            Divider()
            
            // Bottom section: Details
            HStack(spacing: 0) {
                // Temperature
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "thermometer.medium")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("Temperature")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(String(format: "%.1f°C", weather.temperature))
                        .font(.title3.bold())
                        .foregroundColor(LeafyTheme.Colors.text)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 40)
                
                // Humidity
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Humidity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(String(format: "%.0f%%", weather.humidity))
                        .font(.title3.bold())
                        .foregroundColor(LeafyTheme.Colors.text)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
        }
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(overallAdvice.2.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Weather Loading Card
struct WeatherLoadingCard: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(LeafyTheme.Colors.accent)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Loading weather conditions...")
                    .font(.subheadline)
                    .foregroundColor(LeafyTheme.Colors.text)
                
                Text("Getting local environmental data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Weather Info Model
struct DashboardWeatherInfo {
    let temperature: Double
    let humidity: Double
}

// MARK: - Today's Care Section
struct TodaysCareSection: View {
    let plants: [Plant]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(LeafyTheme.Colors.accent)
                Text("Today's Care")
                    .font(.title2.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
            }

            if plants.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(LeafyTheme.Colors.success)
                    Text("All caught up! No tasks for today.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LeafyTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(plants.prefix(5)) { plant in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(plant.commonName)
                                    .font(.headline)
                                    .foregroundColor(LeafyTheme.Colors.text)
                                Text("Water due soon")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(width: 140)
                            .background(LeafyTheme.Colors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// Optional mini card component
struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .padding(10)
                .background(color)
                .clipShape(Circle())

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(LeafyTheme.Colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppState())
    }
}
