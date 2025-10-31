//
//  GPlantDetailView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//

import SwiftUI

struct GuestPlantDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let plant: Plant

    @State private var showAuth = false

    var body: some View {
        // Keep a local NavigationStack so title styling still works,
        // but explicitly hide any system back button.
        NavigationStack {
            ZStack {
                LeafyTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        // Header image
                        headerImage

                        // Identification summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Identification")
                                .font(.headline)
                                .foregroundColor(LeafyTheme.Colors.accent)

                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(LeafyTheme.Colors.success)
                                Text(plant.commonName)
                                    .font(.title3.bold())
                                    .foregroundColor(LeafyTheme.Colors.text)
                            }

                            Text(plant.scientificName)
                                .font(.subheadline.italic())
                                .foregroundColor(.secondary)

                            if let score = plant.confidence {
                                Text("Confidence: \(Int(score * 100))%")
                                    .font(.caption.bold())
                                    .foregroundColor(LeafyTheme.Colors.success)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(LeafyTheme.Colors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Care teaser
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Care Preview")
                                .font(.headline)
                                .foregroundColor(LeafyTheme.Colors.accent)

                            Text("Typical schedule: water every 7–10 days (adjust based on light & humidity).")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Sign up to unlock full adaptive care plans, reminders, and weather-based adjustments.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(LeafyTheme.Colors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // CTAs
                        VStack(spacing: 12) {
                            Button {
                                showAuth = true
                            } label: {
                                Text("Sign Up to Unlock Full Care Plan")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LeafyTheme.primaryGradient)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }

                            Button {
                                dismiss() // back to IdentifyView
                            } label: {
                                Text("Identify Another Plant")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LeafyTheme.Colors.accent.opacity(0.1))
                                    .foregroundColor(LeafyTheme.Colors.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Plant Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // ✅ hide system back entirely
            // ❌ removed toolbar custom back to avoid “two backs”
            .fullScreenCover(isPresented: $showAuth) {
                AuthSelectionView()
            }
        }
    }

    // MARK: Header image
    private var headerImage: some View {
        ZStack(alignment: .bottomTrailing) {
            // Prefer local data if present, else use URL, else placeholder
            if let data = plant.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let urlStr = plant.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .empty, .failure:
                        Rectangle().fill(Color.gray.opacity(0.2))
                    @unknown default:
                        Rectangle().fill(Color.gray.opacity(0.2))
                    }
                }
            } else {
                Rectangle().fill(Color.gray.opacity(0.2))
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.33)
        .clipped()
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
            .background(.black.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(12)
        }
    }

    // MARK: - (Optional) Fallback image block retained for reuse
    private var fallbackImage: some View {
        Group {
            if let data = plant.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("plant_placeholder")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(height: 260)
        .clipped()
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
            .background(.black.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(12)
        }
    }
}


#Preview {
    GuestPlantDetailView(
        plant: Plant(
            commonName: "Aloe Vera",
            scientificName: "Aloe barbadensis miller",
            confidence: 0.93,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Aloe_vera_flower.JPG"
        )
    )
    .environmentObject(AppState())
}

