//
//  ColorExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Foundation
import SwiftUI

extension Color {
    func withAlpha(_ alpha: CGFloat) -> Color {
        return Color(uiColor: UIColor(self).withAlphaComponent(alpha))
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 8:
            (red, green, blue, alpha) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (red, green, blue, alpha) = (0, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    var hexString: String? {
        return UIColor(self).hexString
    }
}

extension Color {
    var cgColor: CGColor {
        return UIColor(self).cgColor
    }

    var inverted: Color {
        var uiColor = UIColor(self)
        var alpha: CGFloat = 0
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Color(red: 1.0 - Double(red), green: 1.0 - Double(green), blue: 1.0 - Double(blue), opacity: Double(alpha))
    }

    static var random: Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }

    var isDark: Bool {
        var uiColor = UIColor(self)
        var alpha: CGFloat = 0
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        return brightness < 0.5
    }

    var toDeviceRGB: Color {
        let components = self.cgColor.components
        guard let components else { return self }

        guard let cgColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: components) else { return self }
        let uiColor = UIColor(cgColor: cgColor)

        return Color(uiColor: uiColor)
    }
}
