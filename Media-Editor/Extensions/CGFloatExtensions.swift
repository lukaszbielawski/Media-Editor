//
//  CGFloatExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import Foundation

extension CGFloat {
    var toPercentage: CGFloat {
        return (self  * 100.0).rounded()
    }
}
