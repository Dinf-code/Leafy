//
//  AddPlantView.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//

import SwiftUI
import PhotosUI

struct AddPlantView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = PlantStore.shared
    
    @State private var showIdentify = false
    @State private var showingSuccess = false
    @State private var showImagePicker = false
    
    // Manual entry fields
    @State private var plantType = ""
    @State private var nickname = ""
    @State private var selectedImage: UIImage?
    @State private var selectedCareStatus: CareStatus = .justWatered
    
    enum CareStatus: String, CaseIterable {
        case justWatered = "Just Watered"
        case justFertilized = "Just Fertilized"
        case justRepotted = "Just Re-potted"
        
        var icon: String {
            switch self {
            case .justWatered: return "drop.fill"
            case .justFertilized: return "leaf.fill"
            case .justRepotted: return "arrow.up.bin.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .justWatered: return .blue
            case .justFertilized: return LeafyTheme.Colors.accent
            case .justRepotted: return .orange
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LeafyTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        cameraSection
                        dividerSection
                        manualEntrySection
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(LeafyTheme.Colors.accent)
                }
            }
            .fullScreenCover(isPresented: $showIdentify) {
                IdentifyView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .alert("Plant Added!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(successMessage)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(LeafyTheme.Colors.accent)
            
            Text("Add a New Plant")
                .font(.title.bold())
                .foregroundColor(LeafyTheme.Colors.text)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Camera Section
    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(LeafyTheme.Colors.accent)
                Text("Identify with Camera")
                    .font(.headline)
                    .foregroundColor(LeafyTheme.Colors.text)
            }
            
            Text("Not sure what plant you have? Let us identify it first.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showIdentify = true }) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                        .font(.title2)
                    Text("Use Camera")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(LeafyTheme.primaryGradient)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // MARK: - Divider Section
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
            Text("OR")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Manual Entry Section
    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(LeafyTheme.Colors.accent)
                Text("Add Manually")
                    .font(.headline)
                    .foregroundColor(LeafyTheme.Colors.text)
            }
            
            // 🆕 Image Picker Button
            imagePicker
            
            plantTypeField
            nicknameField
            careStatusSection
            addPlantButton
        }
        .padding()
        .background(LeafyTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // MARK: - 🆕 Image Picker
    private var imagePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plant Photo")
                .font(.subheadline.bold())
                .foregroundColor(LeafyTheme.Colors.text)
            
            Button(action: { showImagePicker = true }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                        Text("Add Photo")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(LeafyTheme.Colors.background)
                    .foregroundColor(LeafyTheme.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundColor(LeafyTheme.Colors.accent.opacity(0.3))
                    )
                }
            }
        }
    }
    
    // MARK: - Plant Type Field
    private var plantTypeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plant Type")
                .font(.subheadline.bold())
                .foregroundColor(LeafyTheme.Colors.text)
            
            TextField("e.g., Monstera, Snake Plant", text: $plantType)
                .padding()
                .background(LeafyTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Nickname Field
    private var nicknameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Nickname")
                    .font(.subheadline.bold())
                    .foregroundColor(LeafyTheme.Colors.text)
                Text("(Optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextField("e.g., Monty, Office Plant", text: $nickname)
                .padding()
                .background(LeafyTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LeafyTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Care Status Section
    private var careStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Initial Care Status")
                .font(.subheadline.bold())
                .foregroundColor(LeafyTheme.Colors.text)
            
            HStack(spacing: 12) {
                ForEach(CareStatus.allCases, id: \.self) { status in
                    CareStatusButton(
                        status: status,
                        isSelected: selectedCareStatus == status
                    ) {
                        selectedCareStatus = status
                    }
                }
            }
        }
    }
    
    // MARK: - Add Plant Button
    private var addPlantButton: some View {
        Button(action: handleAddPlant) {
            Text("Add Plant")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if plantType.isEmpty {
                            Color.secondary
                        } else {
                            LeafyTheme.primaryGradient
                        }
                    }
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(plantType.isEmpty)
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties
    private var successMessage: String {
        let name = nickname.isEmpty ? plantType : nickname
        return "\(name) has been added to your garden."
    }
    
    // MARK: - Methods
    private func handleAddPlant() {
        let nextWateringDate = calculateNextWateringDate()
        
        // 🔥 Convert image to URL string (save to temp and get URL)
        let imageURL = saveImageAndGetURL(selectedImage)
        
        let newPlant = Plant(
            commonName: nickname.isEmpty ? plantType : nickname,
            scientificName: plantType,
            confidence: nil,
            imageURL: imageURL, // ✅ Now includes image!
            nextWateringDate: nextWateringDate
        )
        
        store.add(newPlant)
        
        // Schedule reminder
        ReminderManager.shared.scheduleReminder(for: newPlant, on: nextWateringDate)
        
        showingSuccess = true
    }
    
    private func calculateNextWateringDate() -> Date {
        let calendar = Calendar.current
        let daysToAdd: Int
        
        switch selectedCareStatus {
        case .justWatered:
            daysToAdd = 7
        case .justFertilized:
            daysToAdd = 3
        case .justRepotted:
            daysToAdd = 5
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
    }
    
    // 🔥 Save image and return URL
    private func saveImageAndGetURL(_ image: UIImage?) -> String? {
        guard let image = image,
              let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let filename = UUID().uuidString + ".jpg"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            print("❌ Failed to save image: \(error)")
            return nil
        }
    }
}

// MARK: - Care Status Button
struct CareStatusButton: View {
    let status: AddPlantView.CareStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: status.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : status.color)
                
                Text(status.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : LeafyTheme.Colors.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? status.color : LeafyTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? status.color : status.color.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

#Preview {
    AddPlantView()
        .environmentObject(AppState())
}
