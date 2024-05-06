//
//  CropShapeType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import Foundation
import SwiftUI

enum CropShapeType: CaseIterable, Hashable {
    static var allCases: [CropShapeType] =
        [.custom(pathPoints: []),
         .rectangle,
         .ellipse,
         .triangle,
         .flippedTriangle,
         .hexagon]

    case custom(pathPoints: [UnitPoint])
    case rectangle
    case ellipse
    case triangle
    case flippedTriangle
    case hexagon

    @ShapeBuilder
    var shape: some Shape {
        switch self {
        case .custom(let pathPoints):
            CustomPath(pathPoints: pathPoints)
        case .rectangle:
            Rectangle()
        case .ellipse:
            Ellipse()
        case .triangle:
            Triangle()
        case .flippedTriangle:
            FlippedTriangle()
        case .hexagon:
            Hexagon()
        }
    }

    var isCustomShape: Bool {
        if case .custom = self {
            return true
        }
        return false
    }

    var iconName: String {
        return switch self {
        case .custom:
            "rectangle.custom"
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
