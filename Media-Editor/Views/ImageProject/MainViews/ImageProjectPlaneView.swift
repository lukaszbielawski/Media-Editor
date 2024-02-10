//
//  ImageProjectPlaneView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectPlaneView: View {
    @EnvironmentObject private var vm: ImageProjectViewModel

    @GestureState private var lastPosition: CGPoint?

    let (minScale, maxScale) = (1.0, 10.0)
    let (previewMinScale, previewMaxScale) = (0.2, 20.0)

    @State var lastScaleValue: Double? = 1.0

    var body: some View {
        ZStack {
            Color.clear
                .frame(minWidth: vm.plane.size?.width ?? 0,
                       maxWidth: .infinity,
                       minHeight: vm.plane.size?.height ?? 0,
                       maxHeight: .infinity)
                .contentShape(Rectangle())
                .zIndex(Double(Int.min + 1))
                .geometryAccessor { workspaceGeoProxy in
                    DispatchQueue.main.async {
                        vm.workspaceSize = workspaceGeoProxy.size
                        vm.plane.setupPlaneView(workspaceSize: workspaceGeoProxy.size)
                        vm.centerButtonFunction = centerPerspective
                    }
                }

            ImageProjectFrameView()
                .zIndex(Double(Int.min + 2))

            ForEach(vm.projectLayers.filter { $0.positionZ != nil }) { layerModel in
                ImageProjectLayerView(
                    layerModel: layerModel
                )
                .zIndex(Double(layerModel.positionZ ?? 0))
            }
        }
        .position(vm.plane.currentPosition ?? .zero)
        .onChange(of: vm.frame.rect) { frameViewRect in
            guard let frameViewRect, let workspaceSize = vm.workspaceSize else { return }

            vm.plane.size =
                CGSize(width: frameViewRect.width + workspaceSize.width * 2.0,
                       height: frameViewRect.height + workspaceSize.height * 2.0)
        }

        .gesture(
            DragGesture()
                .onChanged { value in
                    guard let currentPosition = vm.plane.currentPosition else { return }
                    var newPosition = lastPosition ?? currentPosition
                    newPosition.x += value.translation.width
                    newPosition.y += value.translation.height

                    try? vm.updateFramePosition(newPosition: newPosition, tolerance: 0)
                }
                .updating($lastPosition) { _, startPosition, _ in
                    startPosition = startPosition ?? vm.plane.currentPosition
                }
                .onEnded { _ in
                    guard let currentPosition = vm.plane.currentPosition else { return }
                    do {
                        try vm.updateFramePosition(newPosition: currentPosition)
                    } catch let edgeError as EdgeOverflowError {
                        withAnimation(Animation.linear(duration: 0.2)) {
                            switch edgeError {
                            case .leading(let offset):
                                vm.plane.currentPosition?.x += offset
                            case .trailing(let offset):
                                vm.plane.currentPosition?.x -= offset
                            case .top(let offset):
                                vm.plane.currentPosition?.y += offset
                            case .bottom(let offset):
                                vm.plane.currentPosition?.y -= offset
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
        )
        .scaleEffect(vm.plane.scale ?? 1.0)
        .animation(.bouncy(duration: 0.2), value: vm.plane.scale)
        .highPriorityGesture(TapGesture(count: 2).onEnded {
            guard let scale = vm.plane.scale else { return }
            if scale < 1.5 {
                vm.plane.scale = 2.0
            } else {
                vm.plane.scale = 1.0
            }
        })
        .onTapGesture {
            vm.activeLayer = nil
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    DispatchQueue.main.async {
                        guard let scale = vm.plane.scale else { return }
                        let delta = value / (lastScaleValue ?? 1.0)
                        vm.plane.scale = min(max(scale * delta, previewMinScale), previewMaxScale)
                        lastScaleValue = value
                    }
                }
                .onEnded { _ in
                    guard let scale = vm.plane.scale else { return }
                    if scale > maxScale {
                        vm.plane.scale = min(maxScale, scale)
                    } else {
                        vm.plane.scale = max(minScale, scale)
                    }

                    lastScaleValue = 1.0
                }
        )
    }

    private func centerPerspective() {
        guard let initialPosition = vm.plane.initialPosition, let currentPosition = vm.plane.currentPosition else { return }
        let distance = hypot(currentPosition.x - initialPosition.x, currentPosition.y - initialPosition.y)

        let animationDuration: Double = distance / 2000.0 + 0.2

        withAnimation(.easeInOut(duration: animationDuration)) {
            vm.plane.currentPosition = initialPosition
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.linear(duration: 0.2)) {
                vm.plane.scale = 1.0
            }
        }
    }
}
