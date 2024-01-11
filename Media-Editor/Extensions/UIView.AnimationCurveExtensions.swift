//
//  UIView.AnimationCurveExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Foundation
import SwiftUI

extension UIView.AnimationCurve {
    func convertToAnimation(withDuration duration: Double) -> Animation {
        let timing = UICubicTimingParameters(animationCurve: self)
        return Animation.timingCurve(
            Double(timing.controlPoint1.x),
            Double(timing.controlPoint1.y),
            Double(timing.controlPoint2.x),
            Double(timing.controlPoint2.y),
            duration: duration
        )
    }
}
