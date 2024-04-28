//
//  LayerMergeable.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import Foundation
import SwiftUI

protocol LayerMergeable {
    var positionZ: Int? { get set }
    var scaleX: Double? { get set }
    var scaleY: Double? { get set }
    var rotation: Angle? { get set }
    var position: CGPoint? { get set }
    var cgImage: CGImage? { get set }
    var pixelSize: CGSize { get }
    var pixelToDigitalWidthRatio: CGFloat { get }
    var pixelToDigitalHeightRatio: CGFloat { get }
}
