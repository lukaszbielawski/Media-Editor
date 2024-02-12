//
//  EditFrameToolModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation
import SwiftUI

struct ImageProjectEditingFrameView<Content: View>: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @ObservedObject var layerModel: LayerModel

    @State var opacity = 0.0
    @State var isVisible = false

    @GestureState var lastAngle: Angle?
    @GestureState var lastPosition: CGPoint?
    @GestureState var lastScaleX: Double?
    @GestureState var lastScaleY: Double?

    @ViewBuilder var content: Content

    var isActive: Bool { vm.activeLayer == layerModel }
    let minDimension: Double = 40.0

    var planeScaleFactor: CGFloat { (vm.plane.scale ?? 1.0) - 1.0 }

    var body: some View {
        ZStack {
            if isVisible {
                RoundedRectangle(cornerRadius: 2.0)
                    .fill(Color(.image))
                    .padding(14 + 0.2 * planeScaleFactor)
                    .frame(width: (layerModel.size?.width ?? 0.0) * abs(layerModel.scaleX ?? 1.0) + 42,
                           height: (layerModel.size?.height ?? 0.0) * abs(layerModel.scaleY ?? 1.0) + 42)
                    .opacity(opacity)
                    .overlay {
                        content
                            .modifier(LayerTransformationModifier(scaleX: layerModel.scaleX, scaleY: layerModel.scaleY))
                    }
                    // delete
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "xmark")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .contentShape(Circle())
                            .gesture(deleteGesture)
                    }
                    // rotation
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "crop.rotate")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .gesture(halfPiRotationGesture)
                            .gesture(rotationGesture)
                    }
                    // aspectScale
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .gesture(aspectScaleGesture)
                    }
                    // flip
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .gesture(flipGesture)
                    }
                    // topScale
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .top))
                            .opacity(opacity)
                            .gesture(topScaleGesture)
                    }
                    // bottomScale
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .bottom))
                            .opacity(opacity)
                            .gesture(bottomScaleGesture)
                    }
                    // leadingScale
                    .overlay(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .leading))
                            .opacity(opacity)
                            .gesture(leadingScaleGesture)
                    }
                    // trailingScale
                    .overlay(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .trailing))
                            .opacity(opacity)
                            .gesture(trailingScaleGesture)
                    }
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.35)) {
                            opacity = 1.0
                        }
                    }
            } else {
                content
                    .modifier(LayerTransformationModifier(scaleX: layerModel.scaleX, scaleY: layerModel.scaleY))
            }
        }
        .onChange(of: isActive) { value in
            if value {
                isVisible = true
            } else {
                withAnimation(.easeOut(duration: 0.35)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isVisible = false
                }
            }
        }
    }
}
