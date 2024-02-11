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

//    @Namespace var plane

    var isActive: Bool { vm.activeLayer == layerModel }
    let minDimension: Double = 40.0

    var body: some View {
        ZStack {
            if isVisible {
                RoundedRectangle(cornerRadius: 2.0)

                    .fill(Color(.image))
                    .padding(14)
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
                            .onTapGesture {
                                layerModel.positionZ = nil
                                vm.objectWillChange.send()
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
                                    guard let lastPosition,
                                          let rotation = layerModel.rotation,
                                          let layerSize = layerModel.size else { return }

                                    let dragVector = CGVector(dx: value.location.x - value.startLocation.x,
                                                              dy: value.location.y - value.startLocation.y)

                                    let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                                    let angleBetweenTopEdgeAndDragVector = dragVectorAngle + rotation

                                    let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                                        sin(CGFloat(angleBetweenTopEdgeAndDragVector.radians))

                                    let newScale = (lastScaleY ?? 1.0) + dragLenght / layerSize.height
                                        * copysign(-1.0, layerModel.scaleY ?? 1.0)

                                    guard abs(layerSize.height * newScale) > minDimension,
                                          newScale * (layerModel.scaleY ?? 1.0) > 0.0 else { return }

                                    DispatchQueue.main.async {
                                        layerModel.scaleY = newScale
                                        layerModel.position =
                                            CGPoint(x: lastPosition.x + dragLenght * 0.5
                                                * sin(CGFloat(rotation.radians)),
                                                y: lastPosition.y - dragLenght * 0.5
                                                    * cos(CGFloat(rotation.radians)))
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
                                            ceil(layerModel.rotation!.radians /
                                                (.pi * 0.495)) * (.pi * 0.5) - 0.5 * .pi)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        PersistenceController.shared.saveChanges()
                                    }
                                }
                            }
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let layerCenterPoint = layerModel.position,
                                          let totalNavBarHeight = vm.plane.totalNavBarHeight,
                                          let planeSize = vm.plane.size,
                                          let planeCurrentPosition = vm.plane.currentPosition,
                                          let workspaceSize = vm.workspaceSize else { return }

                                    print("center point of layer is", layerCenterPoint)

                                    let currentDragPoint = CGPoint(x: value.location.x - planeCurrentPosition.x,
                                                                   y: value.location.y - planeCurrentPosition.y)

                                    let previousDragPoint = CGPoint(x: value.startLocation.x - planeCurrentPosition.x,
                                                                    y: value.startLocation.y - planeCurrentPosition.y)

//                                    print("drag current point of layer is", CGPoint(x: value.location.x - planeCurrentPosition.x,
//                                                                                    y: value.location.y - planeCurrentPosition.y))
//                                    print("drag previous point of layer is", CGPoint(x: value.startLocation.x - planeCurrentPosition.x,
//                                                                                     y: value.startLocation.y - planeCurrentPosition.y))

                                    let currentAngle =
                                        Angle(radians: atan2(currentDragPoint.x - layerCenterPoint.x,
                                                             currentDragPoint.y - layerCenterPoint.y))
                                    let previousAngle =
                                        Angle(radians: atan2(previousDragPoint.x - layerCenterPoint.x,
                                                             previousDragPoint.y - layerCenterPoint.y))

                                    let angleDiff = currentAngle - previousAngle

                                    let newAngle = (lastAngle ?? layerModel.rotation ?? .zero) - angleDiff
                                    print("newAngle", Angle(radians: newAngle.normalizedRotation).degrees)
                                    DispatchQueue.main.async {
                                        layerModel.rotation = newAngle
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
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let lastPosition,
                                          let rotation = layerModel.rotation,
                                          let layerSize = layerModel.size else { return }

                                    let dragVector = CGVector(dx: value.location.x - value.startLocation.x,
                                                              dy: value.location.y - value.startLocation.y)

                                    let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                                    let angleBetweenTrailingEdgeAndDragVector = dragVectorAngle + rotation + Angle(radians: .pi * 1.5)

                                    let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                                        sin(CGFloat(angleBetweenTrailingEdgeAndDragVector.radians))

                                    let newScale = (lastScaleX ?? 1.0) - dragLenght / layerSize.width
                                        * copysign(-1.0, layerModel.scaleX ?? 1.0)

                                    guard abs(layerSize.width * newScale) > minDimension,
                                          newScale * (layerModel.scaleX ?? 1.0) > 0.0 else { return }

                                    DispatchQueue.main.async {
                                        layerModel.scaleX = newScale
                                        layerModel.position =
                                            CGPoint(x: lastPosition.x - dragLenght * 0.5
                                                * cos(CGFloat(rotation.radians)),
                                                y: lastPosition.y - dragLenght * 0.5
                                                    * sin(CGFloat(rotation.radians)))
                                    }
                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? layerModel.position
                                }
                                .updating($lastScaleX) { _, lastScaleX, _ in
                                    lastScaleX = lastScaleX ?? layerModel.scaleX
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
                                }
                            )
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
                                          let rotation = layerModel.rotation,
                                          let layerSize = layerModel.size else { return }

                                    var dragVector = CGVector(dx: value.location.x - value.startLocation.x,
                                                              dy: value.location.y - value.startLocation.y)

                                    let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                                    let angleBetweenCornerVectorAndDragVector =
                                        dragVectorAngle + rotation + Angle(radians: 1.25 * .pi)
//
//                                    let dragLenght = hypot(dragVector.dx, dragVector.dy)
//                                        * sin(CGFloat(angleBetweenBottomEdgeAndDragVector.radians))
//
//                                    let dragHeight =
//
//                                    let newScale = (lastScaleY ?? 1.0) + dragLenght / layerSize.height
//                                        * copysign(-1.0, layerModel.scaleY ?? 1.0)
//                                    guard abs(layerSize.height * newScale) > minDimension else { return }

                                    let aspectRatio =
                                        abs((layerSize.width * (layerModel.scaleX ?? 1.0)) /
                                            (layerSize.height * (layerModel.scaleY ?? 1.0)))

                                    if dragVector.dy * aspectRatio > dragVector.dx {
                                        dragVector.dy = dragVector.dx / aspectRatio

                                    } else {
                                        dragVector.dx = dragVector.dy * aspectRatio
                                    }

                                    let newScaleX = (lastScaleX ?? 1.0) + dragVector.dx / layerSize.width
                                        * copysign(-1.0, layerModel.scaleY ?? 1.0)
                                    let newScaleY = (lastScaleY ?? 1.0) + dragVector.dy / layerSize.height
                                        * copysign(-1.0, layerModel.scaleY ?? 1.0)

                                    guard abs(layerSize.width * newScaleX) > minDimension,
                                          abs(layerSize.height * newScaleY) > minDimension,
                                          newScaleX * (layerModel.scaleX ?? 1.0) > 0.0,
                                          newScaleY * (layerModel.scaleY ?? 1.0) > 0.0 else { return }

                                    print(aspectRatio)

                                    DispatchQueue.main.async {
                                        layerModel.scaleX = newScaleX
                                        layerModel.scaleY = newScaleY
//                                        layerModel.position =
//                                            CGPoint(x: lastPosition.x - dragLenght * 0.5
//                                                * sin(CGFloat(rotation.radians)),
//                                                y: lastPosition.y + dragLenght * 0.5
//                                                    * cos(CGFloat(rotation.radians)))
                                        layerModel.position =
                                            CGPoint(x: lastPosition.x + dragVector.dx * 0.5,
                                                    y: lastPosition.y + dragVector.dy * 0.5)
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
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let lastPosition,
                                          let rotation = layerModel.rotation,
                                          let layerSize = layerModel.size else { return }

                                    let dragVector = CGVector(dx: value.location.x - value.startLocation.x,
                                                              dy: value.location.y - value.startLocation.y)

                                    let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                                    let angleBetweenBottomEdgeAndDragVector =
                                        dragVectorAngle + rotation + Angle(radians: .pi)

                                    let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                                        sin(CGFloat(angleBetweenBottomEdgeAndDragVector.radians))

                                    let newScale = (lastScaleY ?? 1.0) + dragLenght / layerSize.height
                                        * copysign(-1.0, layerModel.scaleY ?? 1.0)
                                    guard abs(layerSize.height * newScale) > minDimension,
                                          newScale * (layerModel.scaleY ?? 1.0) > 0.0 else { return }

                                    DispatchQueue.main.async {
                                        layerModel.scaleY = newScale
                                        layerModel.position =
                                            CGPoint(x: lastPosition.x - dragLenght * 0.5
                                                * sin(CGFloat(rotation.radians)),
                                                y: lastPosition.y + dragLenght * 0.5
                                                    * cos(CGFloat(rotation.radians)))
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
                                }
                            )
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
                                    layerModel.scaleY? *= -1.0

                                } else {
                                    layerModel.scaleX? *= -1.0
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
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let lastPosition,
                                          let rotation = layerModel.rotation,
                                          let layerSize = layerModel.size else { return }

                                    let dragVector = CGVector(dx: value.location.x - value.startLocation.x,
                                                              dy: value.location.y - value.startLocation.y)

                                    let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                                    let angleBetweenLeadingEdgeAndDragVector =
                                        dragVectorAngle + rotation + Angle(radians: .pi * 0.5)

                                    let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                                        sin(CGFloat(angleBetweenLeadingEdgeAndDragVector.radians))

                                    let newScale = (lastScaleX ?? 1.0) - dragLenght / layerSize.width
                                        * copysign(-1.0, layerModel.scaleX ?? 1.0)

                                    guard abs(layerSize.width * newScale) > minDimension,
                                          newScale * (layerModel.scaleY ?? 1.0) > 0.0 else { return }
                                    guard let position = layerModel.position else { return }

                                    DispatchQueue.main.async {
                                        layerModel.scaleX = newScale
                                        layerModel.position =
                                            CGPoint(x: lastPosition.x + dragLenght * 0.5
                                                * cos(CGFloat(rotation.radians)),
                                                y: lastPosition.y + dragLenght * 0.5
                                                    * sin(CGFloat(rotation.radians)))
                                    }
                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? layerModel.position
                                }
                                .updating($lastScaleX) { _, lastScaleX, _ in
                                    lastScaleX = lastScaleX ?? layerModel.scaleX
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
                                }
                            )
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
