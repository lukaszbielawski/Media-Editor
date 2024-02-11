//
//  AngleExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 30/01/2024.
//

import Foundation
import SwiftUI

extension Angle {
    var normalizedRotation: Double {
        return self.radians > 0.0
        ? self.radians.truncatingRemainder(dividingBy: 2 * .pi)
        : 2 * .pi + self.radians.truncatingRemainder(dividingBy: -2 * .pi)
    }

    static func + (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians + rhs.radians)
    }

    static func - (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians - rhs.radians)
    }
}
