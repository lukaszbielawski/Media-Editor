//
//  PencilModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

struct PencilModel {
    var currentPencilType: PencilType = .pen
    var currentPencilSize: Int = 16
    var currentPencilColor: Color = Color.black
    var particlesPositions: [CGPoint] = []
}
