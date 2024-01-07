//
//  CGSizeExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Foundation
import CoreGraphics

extension CGSize: Comparable {
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        if (lhs.width * lhs.height) < (rhs.width * rhs.height) {
            return true
        } else {
            return false
        }
    }
    
    
}
