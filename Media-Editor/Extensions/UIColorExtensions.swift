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

        let multiplier = CGFloat(255.999999)

        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(alpha * multiplier),
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
    }
}
