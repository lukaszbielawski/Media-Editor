//
//  CropModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/05/2024.
//

import SwiftUI

struct CropModel {
    var cropRatioType: CropRatioType = .any
    var cropShapeType: CropShapeType = .rectangle
    var currentCropCustomShapeType: CropCustomShapeType = .drag
    var cropOffset: CGSize = .zero
}
