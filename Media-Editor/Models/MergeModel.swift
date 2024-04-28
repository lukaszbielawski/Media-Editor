//
//  MergeModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct MergeModel: LayerMergeable {
    var positionZ: Int?
    
    var scaleX: Double?
    
    var scaleY: Double?
    
    var rotation: Angle?
    
    var position: CGPoint?
    
    var cgImage: CGImage?
    
    var pixelSize: CGSize
    
    var pixelToDigitalWidthRatio: CGFloat
    
    var pixelToDigitalHeightRatio: CGFloat
}
