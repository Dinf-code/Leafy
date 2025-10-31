//
//  LeafyColors.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-04.
//
import SwiftUI

enum LeafyTheme {
    enum Colors {
        // 🌙 DARK MODE ONLY - Beautiful dark green theme
        static let background = Color(red: 0.11, green: 0.13, blue: 0.12)
        static let accent = Color(red: 0.40, green: 0.90, blue: 0.55)
        static let secondary = Color(red: 0.30, green: 0.70, blue: 0.45)
        static let text = Color(red: 0.95, green: 0.98, blue: 0.95)
        static let card = Color(red: 0.16, green: 0.19, blue: 0.17)
        static let success = Color(red: 0.40, green: 0.90, blue: 0.55)
        static let error = Color(red: 0.95, green: 0.40, blue: 0.40)
        static let gray = Color(red: 0.50, green: 0.55, blue: 0.52)
    }

    static let primaryGradient = LinearGradient(
        colors: [Colors.accent, Colors.secondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 20
        static let cardShadow = Color.black.opacity(0.15)
    }

    enum Font {
        static let largeTitle = SwiftUI.Font.system(.largeTitle, design: .rounded).bold()
        static let body = SwiftUI.Font.system(.body, design: .rounded)
        static let caption = SwiftUI.Font.system(.caption, design: .rounded)
    }
}
