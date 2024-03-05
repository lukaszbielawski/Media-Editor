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

    let frameSize: CGSize
    let scaledSize: CGSize

    var initialSize: CGSize {
        .init(width: frameSize.width, height: frameSize.height)
    }

    var initialAspectRatio: CGFloat {
        initialSize.width / initialSize.height
    }

    @State var aspectRatioCorrectionWidth: CGFloat = 1.0
    @State var aspectRatioCorrectionHeight: CGFloat = 1.0

    let resizeCircleSize: CGFloat = 9
    let resizeBorderWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThinMaterial)

            vm.currentCropShape
                .shape
                .border(Color.clear, width: 2)
                .frame(width: initialSize.width * frameScaleWidth * aspectRatioCorrectionWidth,
                       height: initialSize.height * frameScaleHeight * aspectRatioCorrectionHeight)
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
                    aspectRatioCorrectionWidth = min(ratio / initialAspectRatio, 1.0)
                    aspectRatioCorrectionHeight = min(initialAspectRatio / ratio, 1.0)
                } else {
                    aspectRatioCorrectionWidth = 1.0
                    aspectRatioCorrectionHeight = 1.0
                }
            }
        }
    }
}
