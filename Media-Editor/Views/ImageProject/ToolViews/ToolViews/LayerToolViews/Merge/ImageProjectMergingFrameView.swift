//
//  ImageProjectMergingFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/03/2024.
//

import Foundation
import SwiftUI

struct ImageProjectMergingFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @ObservedObject var layerModel: LayerModel

    @GestureState var lastAngle: Angle?
    @GestureState var lastPosition: CGPoint?
    @GestureState var lastScaleX: Double?
    @GestureState var lastScaleY: Double?

    @State var offset: CGFloat = 0.0

    var body: some View {
        ZStack {
            if let planeCurrentPosition = vm.plane.currentPosition,
               let layerPosition = layerModel.position,
               let workspaceSize = vm.workspaceSize,
               let planeScale = vm.plane.scale

            {
                let layerWidth = ceil((layerModel.size?.width ?? 0.0)
                    * abs(layerModel.scaleX ?? 1.0)
                    * planeScale)
                let layerHeight = ceil((layerModel.size?.height ?? 0.0)
                    * abs(layerModel.scaleY ?? 1.0)
                    * planeScale)

                Color
                    .clear
                    .border(Color(.accent), width: 2)
                    .frame(width: layerWidth, height: layerHeight)
                    .rotationEffect(layerModel.rotation ?? .zero)
                    .position(CGPoint(
                        x: (layerPosition.x + planeCurrentPosition.x
                        ) * planeScale
                            - workspaceSize.width * 0.5 * (planeScale - 1.0),
                        y: (layerPosition.y + planeCurrentPosition.y) * planeScale
                            - workspaceSize.height * 0.5 * (planeScale - 1.0)
                    )
                    )
            }
        }
    }
}
