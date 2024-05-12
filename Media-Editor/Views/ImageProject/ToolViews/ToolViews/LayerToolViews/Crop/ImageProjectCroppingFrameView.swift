//
//  ImageProjectCroppingFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/03/2024.
//

import Combine
import Foundation
import SwiftUI

struct ImageProjectCroppingFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState var lastOffset: CGSize?
    @GestureState var lastPathPointsUnitOffset: CGSize?
    @GestureState var lastFrameScaleWidth: Double?
    @GestureState var lastFrameScaleHeight: Double?

    @State var offset: CGSize = .zero
    @State var pathPointsUnitOffset: CGSize = .init(width: 0.0, height: 0.0)
//    @State var lastPathPoints: [UnitPoint] = []
    @State var frameScaleWidth = 1.0
    @State var frameScaleHeight = 1.0
    @State var aspectRatioCorrectionWidth: CGFloat = 1.0
    @State var aspectRatioCorrectionHeight: CGFloat = 1.0

    @State var saveSnapshotSubject = PassthroughSubject<Void, Never>()
    @State var cancellable: AnyCancellable?

    let frameSize: CGSize
    let scaledSize: CGSize

    let resizeCircleSize: CGFloat = 9
    let resizeBorderWidth: CGFloat = 2

    var aspectRatio: CGFloat {
        frameSize.width / frameSize.height
    }

    @GestureState var lastCustomShapeOffset: CGSize?
    @State var customShapeoffset: CGSize = .zero

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.ultraThinMaterial)

            vm.cropModel.cropShapeType.shape
                .fill(Color.white)
                .border(Color.clear, width: 2)
                .frame(width: frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth,
                       height: frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight)
                .blendMode(.destinationOut)
                .overlay(vm.cropModel.cropShapeType.isCustomShape ? nil : resizeFrame)
                .offset(offset)

            if case .custom(let pathPoints) = vm.cropModel.cropShapeType {
                customCroppingFrameView(pathPoints: pathPoints)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        .compositingGroup()
        .gesture({
            if case .custom = vm.cropModel.cropShapeType {
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation

                        let frameWidth = frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth
                        let frameHeight = frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight

                        let unitWidth = translation.width / frameWidth
                        let unitHeight = translation.height / frameHeight

                        var newOffset = lastPathPointsUnitOffset ?? pathPointsUnitOffset

                        let newUnitOffset = UnitPoint(x: newOffset.width + unitWidth, y: newOffset.height + unitHeight)

                        if case .custom(let lastPathPoints) = vm.lastCropModel.cropShapeType {
                            changePathPointsPositions(of: lastPathPoints, offset: newUnitOffset)
                        }
                    }
                    .updating($lastPathPointsUnitOffset) { _, lastPathPointsUnitOffset, _ in
                        lastPathPointsUnitOffset = lastPathPointsUnitOffset ?? pathPointsUnitOffset
                    }
                    .onEnded { [unowned vm] _ in
                        vm.updateLatestSnapshot()
                        vm.lastCropModel = vm.cropModel
                    }
            } else {
                DragGesture()
                    .onChanged { value in
                        var newOffset = lastOffset ?? offset
                        newOffset.width += value.translation.width
                        newOffset.height += value.translation.height

                        offset = newOffset
                    }
                    .updating($lastOffset) { _, lastOffset, _ in
                        lastOffset = lastOffset ?? offset
                    }
                    .onEnded { [unowned vm] _ in
                        vm.updateLatestSnapshot()
                    }
            }
        }()
        )
        .onChange(of: vm.cropModel.cropShapeType) { _ in
            vm.centerButtonFunction?()
        }
        .onChange(of: vm.cropModel.cropRatioType) { cropRatioType in
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
        .onAppear {
            vm.centerButtonFunction = {
                withAnimation(.easeInOut(duration: 0.2)) {
                    frameScaleWidth = 1.0
                    frameScaleHeight = 1.0
                    offset = .zero
                }
            }

            cancellable =
                saveSnapshotSubject
                    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                    .sink { [unowned vm] in
                        vm.updateLatestSnapshot()
                    }

            vm.turnOnCropRevertModel()
        }
        .onDisappear {
            vm.setupCenterButtonFunction()
            vm.cropModel.cropShapeType = .rectangle
        }
        .onReceive(vm.floatingButtonClickedSubject) { [unowned vm] action in
            if action == .confirm {
                Task {
                    guard vm.activeLayer != nil else { return }
                    do {
                        try await vm.cropLayer(
                            frameRect: .init(origin: .zero, size: frameSize),
                            cropRect: .init(origin: .init(x: offset.width, y: offset.height),
                                            size: .init(
                                                width: frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth,
                                                height: frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight)))
                        vm.currentTool = .none
                        vm.updateLatestSnapshot()
                    } catch {
                        print(error)
                    }
                }
                vm.leftFloatingButtonActionType = .back
            }
        }
    }
}
