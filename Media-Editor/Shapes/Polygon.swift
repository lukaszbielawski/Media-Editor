//
//  Polygon.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import Foundation
import SwiftUI

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.5))
        path.closeSubpath()

        return path
    }
}
