//
//  ImageProjectLayerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectLayerView: View {
    var image: PhotoModel
    var body: some View {
        Image(decorative: image.cgImage, scale: 1.0, orientation: .up)
//                    .resizable()
//                    .frame(width: frameWidth, height: frameHeight)
//                    .position(x: frameWidth / 2, y: frameHeight / 2)
//                    .zIndex(Double(positionZ))
    }
}
