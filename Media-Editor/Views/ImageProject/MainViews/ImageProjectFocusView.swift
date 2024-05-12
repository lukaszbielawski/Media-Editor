//
//  ImageProjectFocusView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/03/2024.
//

import SwiftUI

struct ImageProjectFocusView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        if let layerModel = vm.activeLayer,
           let layerModelImage = layerModel.cgImage
        {
            let pixelSize = CGSize(width: layerModel.pixelSize.width * abs(layerModel.scaleX ?? 1.0),
                                   height: layerModel.pixelSize.height * abs(layerModel.scaleY ?? 1.0))

            var frameSize: CGSize {
                return vm.calculateFrameRect(customBounds: pixelSize, isMargined: true)?.size ?? .zero
            }


            ZStack {
                Color(.primary)

                ZStack {
                    Image("AlphaVector")
                        .resizable(resizingMode: .tile)
                        .frame(width: frameSize.width, height: frameSize.height)

                    ZStack {
                        Image(decorative: layerModelImage, scale: 1.0)
                            .resizable()
                            .animation(nil)
                            .frame(width: frameSize.width, height: frameSize.height)
                            .scaleEffect(x: copysign(-1.0, layerModel.scaleX ?? 1.0),
                                         y: copysign(-1.0, layerModel.scaleY ?? 1.0))

                        if let currentTool = vm.currentTool as? LayerToolType {
                            if currentTool == .crop {
                                ImageProjectCroppingFrameView(frameSize: frameSize, scaledSize: pixelSize)
                            } else if currentTool == .draw {
                                ImageProjectDrawingCanvasView(frameSize: frameSize, pixelSize: pixelSize)
                            }
                        }
                    }.compositingGroup()
                }
                .offset(x: 0, y: ((vm.plane.totalLowerToolbarHeight ?? 0.0)
                        - (vm.plane.totalNavBarHeight ?? 0.0)) * 0.5)
            }

            .onReceive(vm.floatingButtonClickedSubject) { action in
                if action == .exitFocusMode {
                    if vm.currentTool is LayerToolType {
                        vm.disablePreviewCGImage()
                    }
                    vm.currentTool = .none
                    vm.currentColorPickerType = .none
                    vm.leftFloatingButtonActionType = .back
                } else if let currentTool = vm.currentTool as? LayerToolType,
                          currentTool == .background
                {
                    if action == .confirm {
                        vm.currentTool = .none
                        vm.currentColorPickerType = .none
                        Task {
                            try await vm.saveNewCGImageOnDisk(
                                fileName: layerModel.fileName,
                                cgImage: layerModel.cgImage)
                        }
                        vm.leftFloatingButtonActionType = .back
                        vm.updateLatestSnapshot()

                    }
                }
            }
        }
    }
}
