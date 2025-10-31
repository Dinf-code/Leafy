//
//  IdentifyViewModel.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//

import SwiftUI
import Combine

@MainActor
final class IdentifyViewModel: ObservableObject {
    @Published var result: Plant?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var capturedImageURL: String? // 🔥 Store image URL
    
    func identify(image: UIImage) async {
        isLoading = true
        errorMessage = nil
        
        // 🔥 Save image first and get URL
        capturedImageURL = saveImageAndGetURL(image)
        
        do {
            // Simulate API call
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Mock plant data - replace with real API
            let plant = Plant(
                commonName: "Monstera Deliciosa",
                scientificName: "Monstera deliciosa",
                confidence: 0.95,
                imageURL: capturedImageURL, // ✅ Include image URL!
                nextWateringDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
            )
            
            result = plant
            isLoading = false
        } catch {
            errorMessage = "Failed to identify plant"
            isLoading = false
        }
    }
    
    // 🔥 Save captured image and return URL
    private func saveImageAndGetURL(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
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
