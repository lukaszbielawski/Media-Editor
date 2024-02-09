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
        if let workspaceSize = vm.workspaceSize,
           let planeSize = vm.plane.size,
           let workspaceSize = vm.workspaceSize,
           let totalLowerToolbarHeight = vm.plane.totalLowerToolbarHeight,
           layerModel.photoEntity.positionX != nil
        {
            ImageProjectEditingFrameView(layerModel: layerModel) {
                Image(decorative: layerModel.cgImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layerModel.size?.width ?? 0, height: layerModel.size?.height ?? 0)
            }
            .onAppear {
                layerModel.position = globalPosition +
                    CGPoint(x: layerModel.photoEntity.positionX as? Double ?? 0.0,
                            y: layerModel.photoEntity.positionY as? Double ?? 0.0)

                layerModel.rotation = Angle(radians: layerModel.photoEntity.rotation as? Double ?? .zero)

                layerModel.scaleX = layerModel.photoEntity.scaleX as? Double ?? 1.0
                layerModel.scaleY = layerModel.photoEntity.scaleY as? Double ?? 1.0
                layerModel.size = vm.calculateLayerSize(photo: layerModel)
                vm.objectWillChange.send()
            }
            .rotationEffect(layerModel.rotation ?? .zero)
            .position(layerModel.position ?? .zero)
            .onTapGesture {
                if vm.activeLayer == layerModel {
                    vm.activeLayer = nil
                } else {
                    vm.activeLayer = layerModel
                }
            }
            .gesture(
                vm.activeLayer == layerModel ?
                    DragGesture()
                    .onChanged { value in

                        var newPosition = lastPosition ?? layerModel.position ?? CGPoint()
                        newPosition.x += value.translation.width
                        newPosition.y += value.translation.height
                        layerModel.position = newPosition

                        guard let position = layerModel.position else { return }
                        layerModel.photoEntity.positionX = (position.x - globalPosition.x) as NSNumber
                        layerModel.photoEntity.positionY = (position.y - globalPosition.y) as NSNumber
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
