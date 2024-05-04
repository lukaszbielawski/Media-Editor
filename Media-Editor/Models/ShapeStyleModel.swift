//
//  ShapeStyleModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 02/05/2024.
//

import SwiftUI

struct ShapeStyleModel {
    private var id: UUID = UUID()
    var shapeStyle: any ShapeStyle {
        willSet {
            id = UUID()
        }
    }
    var shapeStyleCG: Any
    let shapeStyleType: ShapeStyleType

    init(shapeStyle: any ShapeStyle, shapeStyleCG: Any) {
        self.shapeStyle = shapeStyle
        self.shapeStyleCG = shapeStyleCG

        if shapeStyle is Color {
            shapeStyleType = .color
        } else if shapeStyle is LinearGradient {
            shapeStyleType = .gradient
        } else {
            shapeStyleType = .texture
        }
    }
}

extension ShapeStyleModel: Equatable, Hashable {
    static func == (lhs: ShapeStyleModel, rhs: ShapeStyleModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
