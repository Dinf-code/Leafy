//
//  HealthStatus.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-06.
//
import SwiftUI

enum HealthStatus: String, Codable, CaseIterable {
    case healthy
    case warning
    case critical

    /// Returns a color for UI visualization (for dashboard & plant cards)
    var color: Color {
        switch self {
        case .healthy: return .green
        case .warning: return .orange
        case .critical: return .red
        }
    }

    /// Optional description for tooltips or text display
    var description: String {
        switch self {
        case .healthy:
            return "Plant is thriving 🌿"
        case .warning:
            return "Needs attention soon ⚠️"
        case .critical:
            return "Critical care required ❗️"
        }
    }
}
