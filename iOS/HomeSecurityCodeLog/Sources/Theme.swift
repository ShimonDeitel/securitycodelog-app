import SwiftUI

/// Unique palette for Home Security Code Log: warm-to-cool tones fitting its domain.
enum Theme {
    static let background = Color(hex: "1F1111")
    static let surface = Color(hex: "1F1111").opacity(0.001).blendedSurface()
    static let accent = Color(hex: "A53D3D")
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.6)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .default)
}

extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        h.removeAll(where: { $0 == "#" })
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func blendedSurface() -> Color {
        self.opacity(1.0)
    }
}

extension Color {
    static var cardBackground: Color {
        Theme.background.opacity(0.001)
    }
}
