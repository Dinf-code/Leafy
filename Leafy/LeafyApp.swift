//
//  LeafyApp.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//
import SwiftUI

@main
struct LeafyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var coreDataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    // Logged-in user → full app experience
                    MainTabView()
                        .environmentObject(appState)
                        .environmentObject(coreDataManager)

                } else if appState.isGuest {
                    // Guest user → limited Identify mode only
                    FreeTrialView()
                        .environmentObject(appState)
                        .environmentObject(coreDataManager)

                } else {
                    // First-time user → onboarding flow
                    OnboardingFlow()
                        .environmentObject(appState)
                        .environmentObject(coreDataManager) 
                }
            }
        }
    }
}
