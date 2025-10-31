//
//  AppState.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-05.
import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isGuest: Bool = false
    
    // MARK: - Tab Navigation
    enum Tab {
        case identify
        case dashboard
        case settings
    }

    @Published var currentTab: Tab = .identify
}
