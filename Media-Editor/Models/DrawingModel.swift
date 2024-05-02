//
//  DrawingModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

struct DrawingModel {
    var currentPencilType: PencilType = .pen
    var currentPencilSize: Int = 16
    var currentPencilStyle: any ShapeStyle =
    LinearGradient(colors: [Color.red, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    var currentPencilStyleDescription: [String : Any] = [:]
    var particlesPositions: [CGPoint] = []

    func setupPath(_ path: inout Path) {
       

        particlesPositions.forEach { position in
            switch self.currentPencilType {
            case .pen, .eraser:
                path.addLine(to: .init(x: position.x, y: position.y))
                path.move(to: .init(x: position.x, y: position.y))
            case .pencil:
                break
            }
        }
    }
}

extension DrawingModel: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(currentPencilType)
        hasher.combine(currentPencilSize)
        hasher.combine(particlesPositions)
    }

    static func == (lhs: DrawingModel, rhs: DrawingModel) -> Bool {
        return (lhs.currentPencilType, lhs.currentPencilSize, lhs.particlesPositions) ==
            (rhs.currentPencilType, rhs.currentPencilSize, rhs.particlesPositions)
    }
}
