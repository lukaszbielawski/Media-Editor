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
    @State var opacity = 0.0
    @State var isVisible = false

    @ObservedObject var layerModel: LayerModel

    @GestureState var lastAngle: Angle?
    @GestureState var lastPosition: CGPoint?
    @GestureState var lastScaleX: Double?
    @GestureState var lastScaleY: Double?

    @ViewBuilder var content: Content

    var isActive: Bool { vm.activeLayer == layerModel }
    let minDimension: Double = 40.0

    var globalPosition: CGPoint { CGPoint(x: vm.plane.size?.width ?? 0 / 2, y: vm.plane.size?.height ?? 0 / 2) }

    var body: some View {
        ZStack {
            if isVisible {
                RoundedRectangle(cornerRadius: 2.0)

                    .fill(Color(.image))
                    .padding(14)
                    .frame(width: (layerModel.size?.width ?? 0.0) * abs(layerModel.scaleX ?? 1.0) + 42, height: (layerModel.size?.height ?? 0.0) * abs(layerModel.scaleY ?? 1.0) + 42)
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
                            .onTapGesture {
                                layerModel.photoEntity.positionZ = nil
                                let index = vm.projectLayers.firstIndex { $0.id == layerModel.id }
                                guard let index else { return }
                                vm.projectLayers[index].positionZ = nil
                                PersistenceController.shared.saveChanges()
                            }
                    }
                    // topScale
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .top))
                            .opacity(opacity)
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let lastPosition, let layerSize = layerModel.size else { return }

                                    let dragHeight = value.translation.height
                                    var newScale = (lastScaleY ?? 1.0) - dragHeight / layerSize.height

                                    guard layerSize.height * newScale > minDimension else { return }
                                    guard let position = layerModel.position else { return }
                                    DispatchQueue.main.async {
                                        layerModel.scaleY = newScale
                                        layerModel.position?.y = lastPosition.y + dragHeight * 0.5

                                        layerModel.photoEntity.scaleY = layerModel.scaleY as? NSNumber ?? 1.0
                                        layerModel.photoEntity.positionX = (position.x - globalPosition.x) as NSNumber
                                        layerModel.photoEntity.positionY = (position.y - globalPosition.y) as NSNumber

//                                        editAction(.topResize)
                                    }
                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? layerModel.position
                                }
                                .updating($lastScaleY) { _, lastScaleY, _ in
                                    lastScaleY = lastScaleY ?? layerModel.scaleY
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
//                                    editAction(.save)
                                }
                            )
                    }
                    // rotation
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "crop.rotate")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .onTapGesture {
                                if layerModel.rotation != nil {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        layerModel.rotation = Angle(radians:
                                            ceil(layerModel.rotation!.radians / (.pi * 0.495)) * (.pi * 0.5) - 0.5 * .pi)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        layerModel.photoEntity.rotation = NSNumber(value: layerModel.rotation!.radians)
                                        PersistenceController.shared.saveChanges()
                                    }
                                }
                            }
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let position = layerModel.position,
                                          let totalNavBarHeight = vm.plane.totalNavBarHeight,
                                          let layerSize = layerModel.size,
                                          let planeSize = vm.plane.size,
                                          let workspaceSize = vm.workspaceSize else { return }
                                    let centerPoint = CGPoint(x: position.x - planeSize.width * 0.5,
                                                              y: position.y - planeSize.height * 0.5)

                                    let currentDragPoint =
                                        CGPoint(x: value.location.x - workspaceSize.width / 2,
                                                y: value.location.y - (workspaceSize.height + totalNavBarHeight) / 2)

                                    let previousDragPoint =
                                        CGPoint(x: value.startLocation.x - workspaceSize.width / 2,
                                                y: value.startLocation.y - (workspaceSize.height + totalNavBarHeight) / 2)

                                    let currentAngle =
                                        Angle(radians: atan2(currentDragPoint.x - centerPoint.x,
                                                             currentDragPoint.y - centerPoint.y))
                                    let previousAngle =
                                        Angle(radians: atan2(previousDragPoint.x - centerPoint.x,
                                                             previousDragPoint.y - centerPoint.y))

                                    let angleDiff = currentAngle - previousAngle

                                    let newAngle = (lastAngle ?? layerModel.rotation ?? .zero) - angleDiff

                                    DispatchQueue.main.async {
                                        layerModel.rotation = newAngle
                                        layerModel.photoEntity.rotation = NSNumber(value: layerModel.rotation!.radians)
                                    }
                                }
                                .updating($lastAngle) { _, lastAngle, _ in
                                    lastAngle = lastAngle ?? layerModel.rotation
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
                                })
                    }
                    // trailingScale
                    .overlay(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .trailing))
                            .opacity(opacity)
                    }
                    // aspectScale
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let lastPosition,
                                          let lastScaleX,
                                          let lastScaleY,
                                          let layerSize = layerModel.size else { return }

                                    print(layerModel.rotation?.normalizedRotation, "norm")

                                    var dragWidth = value.translation.width
                                    var dragHeight = value.translation.height

                                    print("dragWidth", dragWidth, "dragHeight", dragHeight)

                                    let aspectRatio =
                                        abs((layerSize.width * (layerModel.scaleX ?? 1.0)) /
                                            (layerSize.height * (layerModel.scaleY ?? 1.0)))

                                    let isWidthSmaller = dragHeight * aspectRatio > dragWidth

                                    if isWidthSmaller {
                                        dragHeight = dragWidth / aspectRatio

                                    } else {
                                        dragWidth = dragHeight * aspectRatio
                                    }

                                    let newScaleX = lastScaleX + dragWidth / layerSize.width
                                    let newScaleY = lastScaleY + dragHeight / layerSize.height

                                    let newX = lastPosition.x + dragWidth * 0.5
//                                    * cos(rotation?.normalizedRotation ?? (.pi * 0.5))
                                    let newY = lastPosition.y + dragHeight * 0.5
//                                    * cos(rotation?.normalizedRotation ?? 0)

                                    guard layerSize.width * newScaleX > minDimension,
                                          layerSize.height * newScaleY > minDimension else { return }

                                    DispatchQueue.main.async {
                                        layerModel.scaleX = newScaleX
                                        layerModel.scaleY = newScaleY

                                        layerModel.photoEntity.scaleX = layerModel.scaleX as? NSNumber ?? 1.0
                                        layerModel.photoEntity.scaleY = layerModel.scaleX as? NSNumber ?? 1.0
                                    }
                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? layerModel.position
                                }
                                .updating($lastScaleX) { _, lastScaleX, _ in
                                    lastScaleX = lastScaleX ?? layerModel.scaleX
                                }
                                .updating($lastScaleY) { _, lastScaleY, _ in
                                    lastScaleY = lastScaleY ?? layerModel.scaleY
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
//                                    editAction(.save)
                                }
                            )
                    }
                    // bottomScale
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .bottom))
                            .opacity(opacity)
                    }
                    // flip
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .onTapGesture {
                                let rotation = layerModel.rotation?.normalizedRotation ?? 0.0
                                print(rotation, "norm")
                                if ((.pi * 0.25)...(.pi * 0.75)).contains(rotation) ||
                                    ((.pi * 1.25)...(.pi * 1.75)).contains(rotation)
                                {
                                    let scaleY = layerModel.photoEntity.scaleY
                                    guard let scaleY else { return }

                                    let newScale = NSNumber(value: Double(truncating: scaleY) * -1.0)
                                    layerModel.photoEntity.scaleY = newScale
                                    layerModel.scaleY = Double(truncating: scaleY) * -1.0

                                } else {
                                    let scaleX = layerModel.photoEntity.scaleX
                                    guard let scaleX else { return }

                                    let newScale = NSNumber(value: Double(truncating: scaleX) * -1.0)
                                    layerModel.photoEntity.scaleX = newScale
                                    layerModel.scaleX = Double(truncating: scaleX) * -1.0
                                }
                                PersistenceController.shared.saveChanges()
                            }
                    }
                    // leadingScale
                    .overlay(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .leading))
                            .opacity(opacity)
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

//struct EditFrameCircleModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//
//            .frame(width: 16, height: 16)
//            .padding(10)
//            .background(Circle().fill(Color(.image)))
//    }
//}
//
//struct LayerTransformationModifier: ViewModifier {
//    let scaleX: Double?
//    let scaleY: Double?
//
//    func body(content: Content) -> some View {
//        content
//            .scaleEffect(x: scaleX ?? 1.0, y: scaleY ?? 1.0)
//    }
//}
//
//struct EditFrameResizeModifier: ViewModifier {
//    let edge: Edge.Set
//
//    func body(content: Content) -> some View {
//        ZStack {
//            Circle()
//                .fill(Color(.tint))
//                .frame(width: 13, height: 13)
//            content
//                .frame(width: 14, height: 14)
//                .padding(5)
//        }
//        .padding(edge, 2)
//    }
//}

