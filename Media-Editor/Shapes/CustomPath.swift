//
//  CustomPath.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/05/2024.
//

import SwiftUI

struct CustomPath: Shape, InsettableShape {
    let pathPoints: [UnitPoint]
    var insetAmount: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for unitPoint in pathPoints {
            let x = rect.width * unitPoint.x + insetAmount
            let y = rect.height * unitPoint.y + insetAmount
            if path.isEmpty {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var path = self
        path.insetAmount += amount
        return path
    }
}
