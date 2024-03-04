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

    @ObservedObject var layerModel: LayerModel

    @State var wasPreviousDragGestureFrameLockedForX = false
    @State var wasPreviousDragGestureFrameLockedForY = false

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
                    if let currentTool = vm.currentTool as? ProjectSingleActionToolType,
                       currentTool == .merge
                    {
                        if vm.layersToMerge.contains(layerModel) {
                            vm.layersToMerge.removeAll { $0.fileName == layerModel.fileName }
                        } else {
                            vm.layersToMerge.append(layerModel)
                        }
                    } else {
                        if vm.activeLayer == layerModel {
                            vm.deactivateLayer()
                        } else {
                            vm.activeLayer = layerModel
                            vm.objectWillChange.send()
                        }
                    }
                }
                .gesture(
                    vm.activeLayer == layerModel ?
                        layerDragGesture
                        : nil
                ).onChange(of: vm.plane.lineYPosition) { newValue in
                    if newValue != nil {
                        HapticService.shared.play(.medium)
                    }
                }
                .onChange(of: vm.plane.lineXPosition) { newValue in
                    if newValue != nil {
                        HapticService.shared.play(.medium)
                    }
                }
                .onReceive(vm.performLayerDragPublisher) { translation in
                    if vm.activeLayer == layerModel {
                        layerDragGestureFunction(translation)
                    }
                }
        }
    }
}
