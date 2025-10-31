//
//  AppTheme.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//

import SwiftUI
import Combine

final class AppTheme: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isDarkMode: Bool = false
    
    // MARK: - Methods
    /// Toggle between Light and Dark appearance manually
    func toggleAppearance() {
        isDarkMode.toggle()
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .overrideUserInterfaceStyle = style
        }
    }
}
