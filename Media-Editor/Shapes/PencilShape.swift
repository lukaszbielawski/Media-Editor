//
//  PencilShape.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct PencilShape: Shape {
    let nLines: Int = 7
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lineSpace = rect.width / CGFloat(nLines)
        for i in 0..<nLines {
            var x = (CGFloat(i) * lineSpace) + (CGFloat.random(in: 0...1) * lineSpace)
            path.move(to: CGPoint(x: x, y: rect.minY))
            x = (CGFloat(i) * lineSpace) + (CGFloat.random(in: 0...1) * lineSpace)
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            var y = (CGFloat(i) * lineSpace) + (CGFloat.random(in: 0...1) * lineSpace)
            path.move(to: CGPoint(x: rect.minX, y: y))
            y = (CGFloat(i) * lineSpace) + (CGFloat.random(in: 0...1) * lineSpace)
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}
