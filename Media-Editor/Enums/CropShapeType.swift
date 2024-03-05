//
//  CropShapeType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import Foundation
import SwiftUI

enum CropShapeType: CaseIterable {
    case rectangle
    case ellipse
    case triangle
    case flippedTriangle
    case hexagon

    @ViewBuilder
    var shape: some View {
        switch self {
        case .rectangle:
            Rectangle()
                .fill(.white)
        case .ellipse:
            Ellipse()
                .fill(.white)
        case .triangle:
            Triangle()
                .fill(.white)
        case .flippedTriangle:
            FlippedTriangle()
                .fill(.white)
        case .hexagon:
            Hexagon()
                .fill(.white)
        }
    }

    var iconName: String {
        return switch self {
        case .rectangle:
            "rectangle.fill"
        case .ellipse:
            "oval"
        case .triangle:
            "triangle.fill"
        case .flippedTriangle:
            "triangle.fill"
        case .hexagon:
            "hexagon.fill"
        }
    }

    var isImageFlipped: Bool {
        return switch self {
        case .flippedTriangle:
            true
        default:
            false
        }
    }
}
