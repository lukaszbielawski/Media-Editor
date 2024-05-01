//
//  DrawingModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

struct DrawingModel: Hashable {
    var currentPencilType: PencilType = .pen
    var currentPencilSize: Int = 16
    var currentPencilColor: Color = .black
    var particlesPositions: [CGPoint] = []
}
