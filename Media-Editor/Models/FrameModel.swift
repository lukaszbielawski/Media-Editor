//
//  Frame.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/02/2024.
//

import Foundation
import SwiftUI

struct FrameModel {
    var rect: CGRect?

    let padding: Double = 16.0
    let paddingFactor: Double = 0.05

    var topLeftApexPosition: CGPoint {
        guard let rect else { return .zero }
        return CGPoint(x: rect.minX, y: rect.minY)
    }

    var topRightApexPosition: CGPoint {
        guard let rect else { return .zero }
        return CGPoint(x: rect.maxX, y: rect.minY)
    }

    var bottomLeftApexPosition: CGPoint {
        guard let rect else { return .zero }
        return CGPoint(x: rect.maxX, y: rect.maxY)
    }

    var bottomRightApexPosition: CGPoint {
        guard let rect else { return .zero }
        return CGPoint(x: rect.minX, y: rect.maxY)
    }
}
