//
//  PlantCardView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
//
import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 🖼️ Plant Image
            if let imageURL = plant.imageURL {
                if imageURL.hasPrefix("file://") {
                    // 🔥 Local file URL
                    if let url = URL(string: imageURL),
                       let imageData = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        placeholderImage
                    }
                } else if let url = URL(string: imageURL) {
                    // 🌐 Web URL
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                        case .failure, .empty:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderImage
                }
            } else {
                placeholderImage
            }

            Text(plant.commonName)
                .font(.headline)
                .foregroundColor(LeafyTheme.Colors.text)
                .lineLimit(1)

            Text(plant.scientificName)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(8)
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
        // 🎨 Health status indicator
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(healthColor)
                .frame(width: 12, height: 12)
                .padding(12)
                .shadow(color: healthColor.opacity(0.5), radius: 3)
        }
    }
    
    // 🎨 Health status color
    private var healthColor: Color {
        switch plant.healthStatus {
        case .healthy:
            return .green
        case .warning:
            return .orange
        case .critical:
            return .red
        }
    }
    
    // 🖼️ Placeholder image
    private var placeholderImage: some View {
        ZStack {
            LeafyTheme.Colors.accent.opacity(0.1)
            Image(systemName: "leaf.fill")
                .foregroundStyle(LeafyTheme.Colors.accent)
                .font(.system(size: 40))
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PlantCardView(
        plant: Plant(
            commonName: "Monstera",
            scientificName: "Monstera deliciosa",
            imageURL: "https://images.unsplash.com/photo-1614594975525-e45190c55d0b"
        )
    )
    .preferredColorScheme(.light)
    .padding()
}
