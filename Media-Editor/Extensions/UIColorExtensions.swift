//
//  UIColorExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 26/02/2024.
//

import Foundation
import UIKit

extension UIColor {
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        let multiplier = CGFloat(255)

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let normalizedRed = max(min(Int(red * multiplier), 255), 0)
        let normalizedGreen = max(min(Int(green * multiplier), 255), 0)
        let normalizedBlue = max(min(Int(blue * multiplier), 255), 0)
        let normalizedAlpha = max(min(Int(alpha * multiplier), 255), 0)

        let hexString = String(
            format: "#%02lX%02lX%02lX%02lX",
            normalizedRed,
            normalizedGreen,
            normalizedBlue,
            normalizedAlpha
        )

        return hexString
    }
}
