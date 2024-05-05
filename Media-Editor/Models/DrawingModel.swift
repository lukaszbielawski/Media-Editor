//
//  DrawingModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

struct DrawingModel {
    var currentPencilType: PencilType = .pencil
    var currentPencilSize: Int = 16
    var currentPencilStyle = ShapeStyleModel(shapeStyle: Color.black, shapeStyleCG: UIColor(Color.black).cgColor)
    var particlesPositions: [CGPoint] = []

    func setupPath(_ path: inout Path) {
        particlesPositions.forEach { position in
            path.addLine(to: .init(x: position.x, y: position.y))
            path.move(to: .init(x: position.x, y: position.y))
        }
    }
}

extension DrawingModel: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(currentPencilType)
        hasher.combine(currentPencilSize)
        hasher.combine(currentPencilStyle)
        hasher.combine(particlesPositions)
    }
}
