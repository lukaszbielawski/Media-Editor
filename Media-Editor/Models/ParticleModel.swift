//
//  ParticleModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct ParticleModel {
    let path: Path
    let color: Color

    init(path: Path, color: Color) {
        self.path = path
        self.color = color
    }
}
