//
//  MagicWandModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/05/2024.
//

import SwiftUI

struct MagicWandModel {
    var magicWandType: MagicWandType = .magicWand
    var tolerance: CGFloat = 0.1
    var currentBucketFillShapeStyle = ShapeStyleModel(shapeStyle: Color.white, shapeStyleCG: Color.white.cgColor)
}
