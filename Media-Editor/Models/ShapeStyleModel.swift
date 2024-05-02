//
//  ShapeStyleModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 02/05/2024.
//

import SwiftUI

struct ShapeStyleModel {
    var shapeStyle: any ShapeStyle
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
