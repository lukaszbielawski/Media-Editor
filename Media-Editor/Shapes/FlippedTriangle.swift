//
//  FlippedTriangle.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import Foundation
import SwiftUI

struct FlippedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}
