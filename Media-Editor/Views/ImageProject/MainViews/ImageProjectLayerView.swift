//
//  ImageProjectLayerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectLayerView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState var lastPosition: CGPoint?

    @StateObject var layerModel: LayerModel

    @State var wasPreviousDragGestureFrameLockedForX = false
    @State var wasPreviousDragGestureFrameLockedForY = false

    let dragGestureTolerance = 10.0

    var globalPosition: CGPoint { CGPoint(x: vm.plane.size!.width / 2, y: vm.plane.size!.height / 2) }

    var body: some View {
        if vm.plane.size != nil,
           layerModel.photoEntity.positionX != nil
        {
            ImageProjectEditingFrameView(layerModel: layerModel) {
                Image(decorative: layerModel.cgImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layerModel.size?.width ?? 0, height: layerModel.size?.height ?? 0)
                    .opacity(vm.tools.layersOpacity)
                    .animation(.easeInOut(duration: 0.35), value: vm.tools.layersOpacity)
            }

            .rotationEffect(layerModel.rotation ?? .zero)
            .position((layerModel.position ?? .zero) + globalPosition)
            .onAppear {
                layerModel.size = vm.calculateLayerSize(layerModel: layerModel)
                vm.objectWillChange.send()
            }
            .onTapGesture {
                if vm.activeLayer == layerModel {
                    vm.activeLayer = nil
                } else {
                    vm.activeLayer = layerModel
                }
            }
            .gesture(
                vm.activeLayer == layerModel ?
                    layerDragGesture
                    : nil
            )
        }
    }
}
