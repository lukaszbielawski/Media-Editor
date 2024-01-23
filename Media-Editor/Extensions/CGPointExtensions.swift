//
//  CGPointExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
