//
//  ImageProjectCroppingFrameView+ResizeGestures.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/03/2024.
//

import SwiftUI

extension ImageProjectCroppingFrameView {
    var resizeTopGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                let dragLenght: CGFloat = value.translation.height

                let newScale = (lastFrameScaleHeight ?? 1.0) - dragLenght / frameSize.height
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0)

                guard abs(frameSize.height * newScale) > vm.plane.minDimension,
                      newScale * (lastFrameScaleHeight ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newScale * frameSize.height <= marginedWorkspaceSize.height
                      - (vm.plane.totalNavBarHeight ?? 0.0)

                else { return }

                let newHeight = lastOffset.height + dragLenght * 0.5

                DispatchQueue.main.async {
                    frameScaleHeight = newScale
                    offset = .init(width: lastOffset.width, height: newHeight)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleHeight) { _, lastFrameScaleHeight, _ in
                lastFrameScaleHeight = lastFrameScaleHeight ?? frameScaleHeight
            }
    }

    var resizeBottomGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                let dragLenght: CGFloat = value.translation.height

                let newScale = (lastFrameScaleHeight ?? 1.0) + dragLenght / frameSize.height
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0)

                guard abs(frameSize.height * newScale) > vm.plane.minDimension,
                      newScale * (lastFrameScaleHeight ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newScale * frameSize.height <= marginedWorkspaceSize.height
                      - (vm.plane.totalNavBarHeight ?? 0.0)

                else { return }

                let newHeight = lastOffset.height + dragLenght * 0.5

                DispatchQueue.main.async {
                    frameScaleHeight = newScale
                    offset = .init(width: lastOffset.width, height: newHeight)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleHeight) { _, lastFrameScaleHeight, _ in
                lastFrameScaleHeight = lastFrameScaleHeight ?? frameScaleHeight
            }
    }

    var resizeLeadingGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                let dragLenght: CGFloat = value.translation.width

                let newScale = (lastFrameScaleWidth ?? 1.0) - dragLenght / frameSize.width
                    * copysign(-1.0, lastFrameScaleWidth ?? 1.0)

                guard abs(frameSize.width * newScale) > vm.plane.minDimension,
                      newScale * (lastFrameScaleWidth ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newScale * frameSize.width <= marginedWorkspaceSize.width
                else { return }

                let newWidth = lastOffset.width + dragLenght * 0.5

                DispatchQueue.main.async {
                    frameScaleWidth = newScale
                    offset = .init(width: newWidth, height: lastOffset.height)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleWidth) { _, lastFrameScaleWidth, _ in
                lastFrameScaleWidth = lastFrameScaleWidth ?? frameScaleWidth
            }
    }

    var resizeTrailingGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                let dragLenght: CGFloat = value.translation.width

                let newScale = (lastFrameScaleWidth ?? 1.0) + dragLenght / frameSize.width
                    * copysign(-1.0, lastFrameScaleWidth ?? 1.0)

                guard abs(frameSize.width * newScale) > vm.plane.minDimension,
                      newScale * (lastFrameScaleWidth ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newScale * frameSize.width <= marginedWorkspaceSize.width
                else { return }

                let newWidth = lastOffset.width + dragLenght * 0.5

                DispatchQueue.main.async {
                    frameScaleWidth = newScale
                    offset = .init(width: newWidth, height: lastOffset.height)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleWidth) { _, lastFrameScaleWidth, _ in
                lastFrameScaleWidth = lastFrameScaleWidth ?? frameScaleWidth
            }
    }

    var resizeTopLeadingGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                var dragWidth: CGFloat = value.translation.width
                var dragHeight: CGFloat = value.translation.height

                let oldFrameWidth = abs(frameSize.width * (lastFrameScaleWidth ?? 1.0) *
                    min(aspectRatioCorrectionWidth, 1.0))

                let oldFrameHeight = abs(frameSize.height * (lastFrameScaleHeight ?? 1.0) *
                    min(aspectRatioCorrectionHeight, 1.0))

                let aspectRatio =
                    oldFrameWidth /
                    oldFrameHeight

                dragWidth = -dragHeight * aspectRatio
                dragHeight = -dragWidth / aspectRatio

                let newScaleWidth = (lastFrameScaleWidth ?? 1.0) + dragWidth / frameSize.width
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionWidth, 1.0)
                let newScaleHeight = (lastFrameScaleHeight ?? 1.0) - dragHeight / frameSize.height
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionHeight, 1.0)

                let newFrameWidth = abs(frameSize.width * newScaleWidth *
                    min(aspectRatioCorrectionWidth, 1.0))
                let newFrameHeight = abs(frameSize.height * newScaleHeight *
                    min(aspectRatioCorrectionHeight, 1.0))

                guard newFrameWidth > vm.plane.minDimension,
                      newScaleWidth * (lastFrameScaleWidth ?? 1.0) > 0.0,
                      newFrameHeight > vm.plane.minDimension,
                      newScaleHeight * (lastFrameScaleHeight ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newFrameHeight <= marginedWorkspaceSize.height
                      - (vm.plane.totalNavBarHeight ?? 0.0),
                      newFrameWidth <= marginedWorkspaceSize.width
                else { return }

                let newWidth = lastOffset.width - dragWidth * 0.5
                let newHeight = lastOffset.height + dragHeight * 0.5

                DispatchQueue.main.async {
                    frameScaleWidth = newScaleWidth
                    frameScaleHeight = newScaleHeight
                    offset = .init(width: newWidth, height: newHeight)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleWidth) { _, lastFrameScaleWidth, _ in
                lastFrameScaleWidth = lastFrameScaleWidth ?? frameScaleWidth
            }
            .updating($lastFrameScaleHeight) { _, lastFrameScaleHeight, _ in
                lastFrameScaleHeight = lastFrameScaleHeight ?? frameScaleHeight
            }
    }

    var resizeTopTrailingGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                var dragWidth: CGFloat = value.translation.width
                var dragHeight: CGFloat = value.translation.height

                let oldFrameWidth = abs(frameSize.width * (lastFrameScaleWidth ?? 1.0) *
                    min(aspectRatioCorrectionWidth, 1.0))

                let oldFrameHeight = abs(frameSize.height * (lastFrameScaleHeight ?? 1.0) *
                    min(aspectRatioCorrectionHeight, 1.0))

                let aspectRatio =
                    oldFrameWidth /
                    oldFrameHeight

                dragWidth = -dragHeight * aspectRatio
                dragHeight = -dragWidth / aspectRatio

                let newScaleWidth = (lastFrameScaleWidth ?? 1.0) + dragWidth / frameSize.width
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionWidth, 1.0)
                let newScaleHeight = (lastFrameScaleHeight ?? 1.0) - dragHeight / frameSize.height
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionHeight, 1.0)

                let newFrameWidth = abs(frameSize.width * newScaleWidth *
                    min(aspectRatioCorrectionWidth, 1.0))
                let newFrameHeight = abs(frameSize.height * newScaleHeight *
                    min(aspectRatioCorrectionHeight, 1.0))

                guard newFrameWidth > vm.plane.minDimension,
                      newScaleWidth * (lastFrameScaleWidth ?? 1.0) > 0.0,
                      newFrameHeight > vm.plane.minDimension,
                      newScaleHeight * (lastFrameScaleHeight ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newFrameHeight <= marginedWorkspaceSize.height
                      - (vm.plane.totalNavBarHeight ?? 0.0),
                      newFrameWidth <= marginedWorkspaceSize.width
                else { return }

                let newWidth = lastOffset.width + dragWidth * 0.5
                let newHeight = lastOffset.height + dragHeight * 0.5

                DispatchQueue.main.async {
                    frameScaleWidth = newScaleWidth
                    frameScaleHeight = newScaleHeight
                    offset = .init(width: newWidth, height: newHeight)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleWidth) { _, lastFrameScaleWidth, _ in
                lastFrameScaleWidth = lastFrameScaleWidth ?? frameScaleWidth
            }
            .updating($lastFrameScaleHeight) { _, lastFrameScaleHeight, _ in
                lastFrameScaleHeight = lastFrameScaleHeight ?? frameScaleHeight
            }
    }

    var resizeBottomLeadingGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                var dragWidth: CGFloat = value.translation.width
                var dragHeight: CGFloat = value.translation.height

                let oldFrameWidth = abs(frameSize.width * (lastFrameScaleWidth ?? 1.0) *
                    min(aspectRatioCorrectionWidth, 1.0))

                let oldFrameHeight = abs(frameSize.height * (lastFrameScaleHeight ?? 1.0) *
                    min(aspectRatioCorrectionHeight, 1.0))

                let aspectRatio =
                    oldFrameWidth /
                    oldFrameHeight

                dragWidth = -dragHeight * aspectRatio
                dragHeight = -dragWidth / aspectRatio

                let newScaleWidth = (lastFrameScaleWidth ?? 1.0) - dragWidth / frameSize.width
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionWidth, 1.0)
                let newScaleHeight = (lastFrameScaleHeight ?? 1.0) + dragHeight / frameSize.height
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionHeight, 1.0)

                let newFrameWidth = abs(frameSize.width * newScaleWidth *
                    min(aspectRatioCorrectionWidth, 1.0))
                let newFrameHeight = abs(frameSize.height * newScaleHeight *
                    min(aspectRatioCorrectionHeight, 1.0))

                guard newFrameWidth > vm.plane.minDimension,
                      newScaleWidth * (lastFrameScaleWidth ?? 1.0) > 0.0,
                      newFrameHeight > vm.plane.minDimension,
                      newScaleHeight * (lastFrameScaleHeight ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newFrameHeight <= marginedWorkspaceSize.height
                      - (vm.plane.totalNavBarHeight ?? 0.0),
                      newFrameWidth <= marginedWorkspaceSize.width
                else { return }

                let newWidth = lastOffset.width + dragWidth * 0.5
                let newHeight = lastOffset.height + dragHeight * 0.5

                DispatchQueue.main.async {
                    frameScaleWidth = newScaleWidth
                    frameScaleHeight = newScaleHeight
                    offset = .init(width: newWidth, height: newHeight)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleWidth) { _, lastFrameScaleWidth, _ in
                lastFrameScaleWidth = lastFrameScaleWidth ?? frameScaleWidth
            }
            .updating($lastFrameScaleHeight) { _, lastFrameScaleHeight, _ in
                lastFrameScaleHeight = lastFrameScaleHeight ?? frameScaleHeight
            }
    }

    var resizeBottomTrailingGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastOffset else { return }

                var dragWidth: CGFloat = value.translation.width
                var dragHeight: CGFloat = value.translation.height

                let oldFrameWidth = abs(frameSize.width * (lastFrameScaleWidth ?? 1.0) *
                    min(aspectRatioCorrectionWidth, 1.0))

                let oldFrameHeight = abs(frameSize.height * (lastFrameScaleHeight ?? 1.0) *
                    min(aspectRatioCorrectionHeight, 1.0))

                let aspectRatio =
                    oldFrameWidth /
                    oldFrameHeight

                dragWidth = -dragHeight * aspectRatio
                dragHeight = -dragWidth / aspectRatio

                let newScaleWidth = (lastFrameScaleWidth ?? 1.0) - dragWidth / frameSize.width
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionWidth, 1.0)
                let newScaleHeight = (lastFrameScaleHeight ?? 1.0) + dragHeight / frameSize.height
                    * copysign(-1.0, lastFrameScaleHeight ?? 1.0) /
                    min(aspectRatioCorrectionHeight, 1.0)

                let newFrameWidth = abs(frameSize.width * newScaleWidth *
                    min(aspectRatioCorrectionWidth, 1.0))
                let newFrameHeight = abs(frameSize.height * newScaleHeight *
                    min(aspectRatioCorrectionHeight, 1.0))

                guard newFrameWidth > vm.plane.minDimension,
                      newScaleWidth * (lastFrameScaleWidth ?? 1.0) > 0.0,
                      newFrameHeight > vm.plane.minDimension,
                      newScaleHeight * (lastFrameScaleHeight ?? 1.0) > 0.0,
                      let marginedWorkspaceSize = vm.workspaceSize,
                      newFrameHeight <= marginedWorkspaceSize.height
                      - (vm.plane.totalNavBarHeight ?? 0.0),
                      newFrameWidth <= marginedWorkspaceSize.width
                else { return }

                let newWidth = lastOffset.width - dragWidth * 0.5
                let newHeight = lastOffset.height + dragHeight * 0.5

                DispatchQueue.main.async {
                    frameScaleWidth = newScaleWidth
                    frameScaleHeight = newScaleHeight
                    offset = .init(width: newWidth, height: newHeight)
                }
            }
            .updating($lastOffset) { _, lastOffset, _ in
                lastOffset = lastOffset ?? offset
            }
            .updating($lastFrameScaleWidth) { _, lastFrameScaleWidth, _ in
                lastFrameScaleWidth = lastFrameScaleWidth ?? frameScaleWidth
            }
            .updating($lastFrameScaleHeight) { _, lastFrameScaleHeight, _ in
                lastFrameScaleHeight = lastFrameScaleHeight ?? frameScaleHeight
            }
    }
}
