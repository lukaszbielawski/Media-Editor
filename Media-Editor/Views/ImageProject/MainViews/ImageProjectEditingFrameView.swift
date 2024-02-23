//
//  EditFrameToolModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation
import SwiftUI

struct ImageProjectEditingFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @ObservedObject var layerModel: LayerModel

    @GestureState var lastAngle: Angle?
    @GestureState var lastPosition: CGPoint?
    @GestureState var lastScaleX: Double?
    @GestureState var lastScaleY: Double?

    @State var offset: CGFloat = 0.0
    @State var gestureEnded: Bool = true

    var body: some View {
        ZStack {
            if let planeCurrentPosition = vm.plane.currentPosition,
               let layerPosition = layerModel.position,
               let marginedWorkspaceSize = vm.marginedWorkspaceSize,
               let workspaceSize = vm.workspaceSize,
               let planeScale = vm.plane.scale

            {
                let layerWidth = ceil((layerModel.size?.width ?? 0.0)
                    * abs(layerModel.scaleX ?? 1.0)
                    * planeScale)
                let layerHeight = ceil((layerModel.size?.height ?? 0.0)
                    * abs(layerModel.scaleY ?? 1.0)
                    * planeScale)
                let isFrameBig = layerWidth > marginedWorkspaceSize.width * 0.8 ||
                    layerHeight > marginedWorkspaceSize.height * 0.8
                ZStack {
                    Color
                        .clear
                        .border(Color(.image), width: 2)
                        .padding(isFrameBig ? 16.0 : 40.0)
                        .frame(width: layerWidth +
                            (isFrameBig ? 32.0 : 80.0),
                            height: layerHeight +
                                (isFrameBig ? 32.0 : 80.0))
                        .overlay(alignment: .topLeading) {
                            ZStack(alignment: .topLeading) {
                                if !isFrameBig {
                                    Rectangle()
                                        .foregroundStyle(Color(.image))
                                        .frame(width: 2, height: 24 / sin(.pi * 0.25))
                                        .rotationEffect(Angle(radians: .pi * 1.75), anchor: .topLeading)
                                        .padding(.top, 16.0)
                                        .padding(.leading, 16.0)
                                        .offset(y: 1.5)
                                }
                                Image(systemName: "trash")
                                    .modifier(EditFrameCircleModifier())
                                    .rotationEffect(-layerModel.rotation!)
                                    .shadow(radius: 10.0)
                                    .contentShape(Circle())
                                    .gesture(deleteGesture(layerModel: layerModel))
                            }
                        }
                        // rotation
                        .overlay(alignment: .topTrailing) {
                            ZStack(alignment: .topTrailing) {
                                if !isFrameBig {
                                    Rectangle()
                                        .foregroundStyle(Color(.image))
                                        .frame(width: 2, height: 24 / sin(.pi * 0.25))
                                        .rotationEffect(Angle(radians: .pi * 0.25), anchor: .topTrailing)
                                        .padding(.top, 16.0)
                                        .padding(.trailing, 16.0)
                                        .offset(y: 1.5)
                                }
                                Image(systemName: "crop.rotate")
                                    .modifier(EditFrameCircleModifier())
                                    .rotationEffect(-layerModel.rotation!)
                                    .shadow(radius: 10.0)
                                    .gesture(halfPiRotationGesture(layerModel: layerModel))
                                    .gesture(rotationGesture(layerModel: layerModel))
                            }
                        }
                        // aspectScale
                        .overlay(alignment: .bottomTrailing) {
                            ZStack(alignment: .bottomTrailing) {
                                if !isFrameBig {
                                    Rectangle()
                                        .foregroundStyle(Color(.image))
                                        .frame(width: 2, height: 24 / sin(.pi * 0.25))
                                        .rotationEffect(Angle(radians: .pi * 1.75), anchor: .bottomTrailing)
                                        .padding(.bottom, 16.0)
                                        .padding(.trailing, 16.0)
                                        .offset(y: -1.5)
                                }
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .modifier(EditFrameCircleModifier())
                                    .shadow(radius: 10.0)
                                    .gesture(aspectScaleGesture(layerModel: layerModel))
                            }
                        }
                        // move
                        .overlay(alignment: .bottomLeading) {
                            ZStack(alignment: .bottomLeading) {
                                if !isFrameBig {
                                    Rectangle()
                                        .foregroundStyle(Color(.image))
                                        .frame(width: 2, height: 24 / sin(.pi * 0.25))
                                        .rotationEffect(Angle(radians: .pi * 0.25), anchor: .bottomLeading)
                                        .padding(.bottom, 16.0)
                                        .padding(.leading, 16.0)
                                        .offset(y: -1.5)
                                }
                                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                                    .rotationEffect(-layerModel.rotation!)
                                    .modifier(EditFrameCircleModifier())
                                    .shadow(radius: 10.0)
                                    .gesture(moveGesture(layerModel: layerModel))
                            }
                        }
                        // topScale
                        .overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            Circle()
                                .strokeBorder(Color(.image), lineWidth: 2)
                                .clipShape(Circle())
                                .modifier(EditFrameResizeModifier(offset: $offset))
                                .gesture(topScaleGesture(layerModel: layerModel))
                        }
                        // bottomScale
                        .overlay(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                            Circle()
                                .strokeBorder(Color(.image), lineWidth: 2)
                                .clipShape(Circle())
                                .modifier(EditFrameResizeModifier(offset: $offset))
                                .gesture(bottomScaleGesture(layerModel: layerModel))
                        }
                        // leadingScale
                        .overlay(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                            Circle()
                                .strokeBorder(Color(.image), lineWidth: 2)
                                .clipShape(Circle())
                                .modifier(EditFrameResizeModifier(offset: $offset))
                                .gesture(leadingScaleGesture(layerModel: layerModel))
                        }
                        // trailingScale
                        .overlay(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                            Circle()
                                .strokeBorder(Color(.image), lineWidth: 2)
                                .clipShape(Circle())
                                .modifier(EditFrameResizeModifier(offset: $offset))
                                .gesture(trailingScaleGesture(layerModel: layerModel))
                        }
                }
                .rotationEffect(layerModel.rotation ?? .zero)
                .position(CGPoint(
                    x: (layerPosition.x + planeCurrentPosition.x
                    ) * planeScale
                        - workspaceSize.width * 0.5 * (planeScale - 1.0),
                    y: (layerPosition.y + planeCurrentPosition.y) * planeScale
                        - workspaceSize.height * 0.5 * (planeScale - 1.0)
                )
                )
                .onChange(of: vm.plane.scale) { _ in
                    print(layerPosition)
                    print(planeCurrentPosition)
                }
                .onAppear {
                    if isFrameBig {
                        offset = 0.0
                    } else {
                        offset = 24.0
                    }
                }
                .onChange(of: isFrameBig) { isBig in
                    if isBig {
                        offset = 0.0
                    } else {
                        offset = 24.0
                    }
                }
            }
        }
    }
}
