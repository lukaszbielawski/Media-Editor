//
//  ShapeExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 01/05/2024.
//

import SwiftUI

extension Shape {
    @ViewBuilder func pencilStroke(for drawing: DrawingModel, strokeStyle: StrokeStyle) -> some View {
        switch drawing.currentPencilType {
        case .eraser:
            self
                .stroke(Color.black, style: strokeStyle)
        case .pen, .pencil:
            if let currentPencilShapeStyle = drawing.currentPencilStyle.shapeStyle as? Color {
                self
                    .stroke(currentPencilShapeStyle, style: strokeStyle)
            } else if let currentPencilShapeStyle = drawing.currentPencilStyle.shapeStyle as? LinearGradient {
                self
                    .stroke(currentPencilShapeStyle, style: strokeStyle)
            }
        }
    }
}
