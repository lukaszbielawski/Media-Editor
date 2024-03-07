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
        if let layerModel = vm.activeLayer {
            let scaledSize = CGSize(width: layerModel.pixelSize.width * abs(layerModel.scaleX ?? 1.0),
                                    height: layerModel.pixelSize.height * abs(layerModel.scaleY ?? 1.0))

            var frameSize: CGSize {
                return vm.calculateFrameRect(customBounds: scaledSize, isMargined: true)?.size ?? .zero
            }

            ZStack {
                Color(.primary)

                ZStack {
                    Image("AlphaVector")
                        .resizable(resizingMode: .tile)
                        .frame(width: frameSize.width, height: frameSize.height)

                    Image(decorative: layerModel.cgImage, scale: 1.0)
                        .resizable()
                        .frame(width: frameSize.width, height: frameSize.height)
                        .scaleEffect(x: copysign(-1.0, layerModel.scaleX ?? 1.0),
                                     y: copysign(-1.0, layerModel.scaleY ?? 1.0))

                    if let currentTool = vm.currentTool as? LayerToolType, currentTool == .crop {
                        ImageProjectCroppingFrameView(frameSize: frameSize, scaledSize: scaledSize)
                    }
                }
                .offset(x: 0, y: ((vm.plane.totalLowerToolbarHeight ?? 0.0)
                        - (vm.plane.totalNavBarHeight ?? 0.0)) * 0.5)
            }

            .onReceive(vm.floatingButtonClickedSubject) { action in
                print(action)
                if action == .exitFocusMode {
                    if let currentTool = vm.currentTool as? LayerToolType {
                        print("xd")
                        vm.currentLayerBackgroundColor = Color.clear
                        vm.disablePreviewCGImage()
                    }
                    vm.currentTool = .none
                } else if let currentTool = vm.currentTool as? LayerToolType,
                          currentTool == .background
                {
                    if action == .confirm {
                        vm.currentTool = .none
                        vm.currentLayerBackgroundColor = Color.clear
                        Task {
                            try? await vm.saveNewCGImageOnDisk(
                                fileName: layerModel.fileName,
                                cgImage: layerModel.cgImage)
                        }
                        
                        vm.updateLatestSnapshot()
                    }
                }
            }
        }
    }
}
