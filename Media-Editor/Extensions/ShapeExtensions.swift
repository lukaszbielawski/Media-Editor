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
            if let currentPencilStyle = drawing.currentPencilStyle as? Color {
                self
                    .stroke(currentPencilStyle, style: strokeStyle)
            } else if let currentPencilStyle = drawing.currentPencilStyle as? LinearGradient {
                self
                    .stroke(currentPencilStyle, style: strokeStyle)
            }
        }
    }
}
