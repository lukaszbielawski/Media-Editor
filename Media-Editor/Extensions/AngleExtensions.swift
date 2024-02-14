//
//  AngleExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 30/01/2024.
//

import Foundation
import SwiftUI

extension Angle {
    var normalizedRotationRadians: Double {
        return self.radians > 0.0
            ? self.radians.truncatingRemainder(dividingBy: 2 * .pi)
            : 2 * .pi + self.radians.truncatingRemainder(dividingBy: -2 * .pi)
    }

    var isBelowHalfAngle: Bool {
        return self.normalizedRotationDegrees < 185.0 && self.normalizedRotationDegrees > 5.0
    }

    var isRightAngle: Bool {
        (-0.01 ... 0.01).contains(sin(self.radians * 2))
    }

    var normalizedRotationDegrees: Double {
        return self.degrees > 0.0
            ? self.degrees.truncatingRemainder(dividingBy: 360.0)
            : 360.0 + self.degrees.truncatingRemainder(dividingBy: -360.0)
    }

    static func + (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians + rhs.radians)
    }

    static func - (lhs: Angle, rhs: Angle) -> Angle {
        return Angle(radians: lhs.radians - rhs.radians)
    }
}
