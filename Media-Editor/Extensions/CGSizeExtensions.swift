//
//  CGSizeExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 17/01/2024.
//

import CoreGraphics
import Foundation

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    func pixelSize(_ widthRatio: CGFloat, _ heightRatio: CGFloat) -> CGSize {
        .init(width: self.width * widthRatio, height: self.height * heightRatio)
    }
}
