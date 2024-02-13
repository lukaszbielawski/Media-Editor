//
//  ImageProjectLayerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectLayerView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState private var lastPosition: CGPoint?

    @StateObject var layerModel: LayerModel

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
                    DragGesture(coordinateSpace: .local)
                    .onChanged { value in

                        var newPosition = lastPosition ?? layerModel.position ?? CGPoint()
                        newPosition.x += value.translation.width
                        newPosition.y += value.translation.height
                        layerModel.position = newPosition
                        print("new position", newPosition)
                    }
                    .updating($lastPosition) { _, startPosition, _ in
                        startPosition = startPosition ?? layerModel.position
                    }.onEnded { _ in
                        PersistenceController.shared.saveChanges()
                    }
                    : nil
            )
        }
    }
}
