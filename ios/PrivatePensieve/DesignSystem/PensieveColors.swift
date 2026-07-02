// PensieveColors.swift
// Private Pensieve AI — iOS Design System
// Source of truth: docs/DESIGN_SYSTEM.md

import SwiftUI

extension Color {
    // MARK: - Dark Mode Base Colors
    static let pensieveBackground = Color(hex: "0B0F14")
    static let pensieveSurfacePrimary = Color(hex: "121923")
    static let pensieveSurfaceSecondary = Color(hex: "182230")
    static let pensieveSurfaceElevated = Color(hex: "1E2A38")
    static let pensieveTextPrimary = Color(hex: "F6F7FB")
    static let pensieveTextSecondary = Color(hex: "AAB5C4")
    static let pensieveTextMuted = Color(hex: "7B8797")
    static let pensieveBorder = Color(hex: "2B3A4A")

    // MARK: - Accent Colors
    static let pensieveAccentLavender = Color(hex: "A78BFA")
    static let pensieveAccentViolet = Color(hex: "7C5CFC")
    static let pensieveAccentBlue = Color(hex: "63B3ED")
    static let pensieveAccentTeal = Color(hex: "5ED6C9")
    static let pensieveAccentAmber = Color(hex: "F6C667")
    static let pensieveAccentRed = Color(hex: "F87171")

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
