//
//  ImageProjectCroppingFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/03/2024.
//

import Foundation
import SwiftUI

struct ImageProjectCroppingFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState var lastOffset: CGSize?
    @GestureState var lastFrameScaleWidth: Double?
    @GestureState var lastFrameScaleHeight: Double?

    @State var offset: CGSize = .zero
    @State var frameScaleWidth = 1.0
    @State var frameScaleHeight = 1.0
    @State var aspectRatioCorrectionWidth: CGFloat = 1.0
    @State var aspectRatioCorrectionHeight: CGFloat = 1.0

    let frameSize: CGSize
    let scaledSize: CGSize

    let resizeCircleSize: CGFloat = 9
    let resizeBorderWidth: CGFloat = 2

    var aspectRatio: CGFloat {
        frameSize.width / frameSize.height
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThinMaterial)

            vm.currentCropShape
                .shape
                .fill(Color.white)
                .border(Color.clear, width: 2)
                .frame(width: frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth,
                       height: frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight)
                .blendMode(.destinationOut)
                .overlay(resizeFrame)
                .offset(offset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        .compositingGroup()
        .gesture(DragGesture()
            .onChanged { value in
                var newOffset = lastOffset ?? offset
                newOffset.width += value.translation.width
                newOffset.height += value.translation.height

                offset = newOffset
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
        )
        .onChange(of: vm.currentCropRatio) { cropRatioType in
            let ratio = cropRatioType.value

            withAnimation(.easeInOut(duration: 0.2)) {
                frameScaleWidth = 1.0
                frameScaleHeight = 1.0
                offset = .zero
                if let ratio {
                    aspectRatioCorrectionWidth = min(ratio / aspectRatio, 1.0)
                    aspectRatioCorrectionHeight = min(aspectRatio / ratio, 1.0)
                } else {
                    aspectRatioCorrectionWidth = 1.0
                    aspectRatioCorrectionHeight = 1.0
                }
            }
        }
        .onReceive(vm.floatingButtonClickedSubject) { action in
            if action == .confirm {
                Task {
                    guard vm.activeLayer != nil else { return }
                    try await vm.cropLayer(
                        frameRect: .init(origin: .zero, size: frameSize),
                        cropRect: .init(origin: .init(x: offset.width, y: offset.height),
                                        size: .init(
                                            width: frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth,
                                            height: frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight)))
                    vm.currentTool = .none
                    vm.updateLatestSnapshot()
                }
                vm.leftFloatingButtonActionType = .back
            }
        }
    }
}
