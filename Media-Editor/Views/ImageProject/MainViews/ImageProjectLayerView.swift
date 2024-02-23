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
    @State var gestureEnded = true


    let dragGestureTolerance = 10.0

    var body: some View {
        if vm.plane.size != nil,
           layerModel.photoEntity.positionX != nil
        {
            Image(decorative: layerModel.cgImage, scale: 1.0, orientation: .up)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: layerModel.size?.width ?? 0, height: layerModel.size?.height ?? 0)
                .scaleEffect(x: layerModel.scaleX ?? 1.0, y: layerModel.scaleY ?? 1.0)
                .rotationEffect(layerModel.rotation ?? .zero)
                .position((layerModel.position ?? .zero) + vm.plane.globalPosition)
                .opacity(vm.tools.layersOpacity)
                .animation(.easeInOut(duration: 0.35), value: vm.tools.layersOpacity)
                .onAppear {
                    layerModel.size = vm.calculateLayerSize(layerModel: layerModel)
                    vm.objectWillChange.send()
                }
                .onTapGesture {
                    if vm.activeLayer == layerModel {
                        vm.activeLayer = nil
                    } else {
                        vm.activeLayer = layerModel
                        vm.objectWillChange.send()
                    }
                }
                .gesture(
                    vm.activeLayer == layerModel ?
                        layerDragGesture
                        : nil
                )
                .onReceive(vm.performLayerDragPublisher) { translation in
                    if vm.activeLayer == layerModel {
                        layerDragGestureFunction(translation)
                    }
                }
        }
    }
}
