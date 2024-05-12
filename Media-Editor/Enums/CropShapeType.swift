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

    struct Points {
        let minX: CGFloat
        let maxX: CGFloat
        let minY: CGFloat
        let maxY: CGFloat
        
        var unitWidth: CGFloat {
            return maxX - minX
        }

        var unitHeight: CGFloat {
            return maxY - minY
        }

        var midX: CGFloat {
            return (minX + maxX) * 0.5
        }

        var midY: CGFloat {
            return (minY + maxY) * 0.5
        }

//        init(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
//            self.minX = max(minX, 0.0)
//            self.maxX = min(maxX, 1.0)
//            self.minY = max(minY, 0.0)
//            self.maxY = min(maxY, 1.0)
//        }
    }

    var shapePoints: Points {


        if case .custom(let pathPoints) = self {
            var minX = Double(Int.max)
            var maxX = Double(Int.min)
            var minY = Double(Int.max)
            var maxY = Double(Int.min)

            for point in pathPoints {
                minX = min(minX, point.x)
                maxX = max(maxX, point.x)
                minY = min(minY, point.y)
                maxY = max(maxY, point.y)
            }
            return Points(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        }
        return Points(minX: 0.0, maxX: 1.0, minY: 0.0, maxY: 1.0)

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
