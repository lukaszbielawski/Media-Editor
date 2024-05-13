//
//  SnapshotModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Foundation

struct SnapshotModel {
    let layers: [LayerModel]
    let projectModel: ImageProjectModel
    let drawings: [DrawingModel]
    let currentDrawing: DrawingModel
    let cropModel: CropModel
    let magicWandModel: MagicWandModel
}
