//
//  ParticlesModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct ParticlesModel {
    let path: Path
    let color: Color
    var positions: [CGPoint] = []

    init(path: Path, color: Color) {
        self.path = path
        self.color = color
    }
}
