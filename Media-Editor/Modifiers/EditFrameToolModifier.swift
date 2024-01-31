//
//  EditFrameToolModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation
import SwiftUI

struct EditFrameToolModifier: ViewModifier {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var opacity = 0.0
    @State var isVisible = false

    @Binding var image: PhotoModel
    @Binding var rotation: Angle?
    @Binding var position: CGPoint?
    @Binding var scaleX: Double?
    @Binding var scaleY: Double?

    @GestureState var lastAngle: Angle?
    @GestureState var lastPosition: CGPoint?
    @GestureState var lastScaleX: Double?
    @GestureState var lastScaleY: Double?

    let isActive: Bool
    let geoSize: CGSize
    let planeSize: CGSize
    let layerSize: CGSize?
    var totalNavBarHeight: Double?
    let minDimension: Double = 40.0

    var globalPosition: CGPoint { CGPoint(x: planeSize.width / 2, y: planeSize.height / 2) }

    func body(content: Content) -> some View {
        ZStack {
            if isVisible {
                RoundedRectangle(cornerRadius: 2.0)

                    .fill(Color(.image))
                    .padding(14)
                    .frame(width: (layerSize?.width ?? 0.0) * abs(scaleX ?? 1.0) + 42, height: (layerSize?.height ?? 0.0) * abs(scaleY ?? 1.0) + 42)
                    .opacity(opacity)
                    .overlay {
                        content
                            .modifier(LayerTransformationModifier(scaleX: scaleX, scaleY: scaleY))
                    }
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "xmark")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .contentShape(Circle())
                            .onTapGesture {
                                image.photoEntity.positionZ = nil
                                let index = vm.projectPhotos.firstIndex { $0.id == image.id }
                                guard let index else { return }
                                vm.projectPhotos[index].positionZ = nil
                                PersistenceController.shared.saveChanges()
                            }
                    }
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .top))
                            .opacity(opacity)
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let lastPosition, let layerSize else { return }

                                    let dragHeight = value.translation.height
                                    var newScale = (lastScaleY ?? 1.0) - dragHeight / layerSize.height

                                    guard layerSize.height * newScale > minDimension else { return }
                                    guard let position else { return }
                                    DispatchQueue.main.async {
                                        scaleY = newScale
                                        self.position?.y = lastPosition.y + dragHeight * 0.5

                                        image.photoEntity.scaleY = scaleY as? NSNumber ?? 1.0
                                        image.photoEntity.positionX = (position.x - globalPosition.x) as NSNumber
                                        image.photoEntity.positionY = (position.y - globalPosition.y) as NSNumber

//                                        editAction(.topResize)
                                    }
                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? position
                                }
                                .updating($lastScaleY) { _, lastScaleY, _ in
                                    lastScaleY = lastScaleY ?? scaleY
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
//                                    editAction(.save)
                                }
                            )
                    }
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "crop.rotate")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .onTapGesture {
                                if rotation != nil {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        self.rotation = Angle(radians:
                                            ceil(self.rotation!.radians / (.pi * 0.495)) * (.pi * 0.5) - 0.5 * .pi)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        image.photoEntity.rotation = NSNumber(value: rotation!.radians)
                                        PersistenceController.shared.saveChanges()
                                    }
//                                    editAction(.rotateLeft)
                                }
                            }
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let position, let totalNavBarHeight, let layerSize else { return }
                                    let centerPoint = CGPoint(x: position.x - planeSize.width * 0.5,
                                                              y: position.y - planeSize.height * 0.5)

                                    let currentDragPoint =
                                        CGPoint(x: value.location.x - geoSize.width / 2,
                                                y: value.location.y - (geoSize.height + totalNavBarHeight) / 2)

                                    let previousDragPoint =
                                        CGPoint(x: value.startLocation.x - geoSize.width / 2,
                                                y: value.startLocation.y - (geoSize.height + totalNavBarHeight) / 2)

                                    let currentAngle =
                                        Angle(radians: atan2(currentDragPoint.x - centerPoint.x,
                                                             currentDragPoint.y - centerPoint.y))
                                    let previousAngle =
                                        Angle(radians: atan2(previousDragPoint.x - centerPoint.x,
                                                             previousDragPoint.y - centerPoint.y))

                                    let angleDiff = currentAngle - previousAngle

                                    let newAngle = (lastAngle ?? rotation ?? .zero) - angleDiff

                                    DispatchQueue.main.async {
                                        rotation = newAngle
                                        image.photoEntity.rotation = NSNumber(value: rotation!.radians)
                                    }
                                }
                                .updating($lastAngle) { _, lastAngle, _ in
                                    lastAngle = lastAngle ?? rotation
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
//                                    editAction(.save)
                                })
                    }
                    .overlay(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .trailing))
                            .opacity(opacity)
                    }
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
                                          let layerSize else { return }

                                    print(rotation?.normalizedRotation, "norm")

                                    var dragWidth = value.translation.width
                                    var dragHeight = value.translation.height

                                    print("dragWidth", dragWidth, "dragHeight", dragHeight)

                                    let aspectRatio =
                                        abs((layerSize.width * (scaleX ?? 1.0)) /
                                            (layerSize.height * (scaleY ?? 1.0)))

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
                                        scaleX = newScaleX
                                        scaleY = newScaleY

//                                        position = CGPoint(x: newX, y: newY)

                                        image.photoEntity.scaleX = scaleX as? NSNumber ?? 1.0
                                        image.photoEntity.scaleY = scaleX as? NSNumber ?? 1.0
                                    }
                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? position
                                }
                                .updating($lastScaleX) { _, lastScaleX, _ in
                                    lastScaleX = lastScaleX ?? scaleX
                                }
                                .updating($lastScaleY) { _, lastScaleY, _ in
                                    lastScaleY = lastScaleY ?? scaleY
                                }
                                .onEnded { _ in
                                    PersistenceController.shared.saveChanges()
//                                    editAction(.save)
                                }
                            )
                    }
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .bottom))
                            .opacity(opacity)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .onTapGesture {
                                let rotation = rotation?.normalizedRotation ?? 0.0
                                print(rotation, "norm")
                                if ((.pi * 0.25)...(.pi * 0.75)).contains(rotation) ||
                                    ((.pi * 1.25)...(.pi * 1.75)).contains(rotation)
                                {
                                    let scaleY = image.photoEntity.scaleY
                                    guard let scaleY else { return }

                                    let newScale = NSNumber(value: Double(truncating: scaleY) * -1.0)
                                    image.photoEntity.scaleY = newScale
                                    self.scaleY = Double(truncating: scaleY) * -1.0

                                } else {
                                    let scaleX = image.photoEntity.scaleX
                                    guard let scaleX else { return }

                                    let newScale = NSNumber(value: Double(truncating: scaleX) * -1.0)
                                    image.photoEntity.scaleX = newScale
                                    self.scaleX = Double(truncating: scaleX) * -1.0
                                }
                                PersistenceController.shared.saveChanges()
                            }
                    }
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
                    .modifier(LayerTransformationModifier(scaleX: scaleX, scaleY: scaleY))
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

struct EditFrameCircleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content

            .frame(width: 16, height: 16)
            .padding(10)
            .background(Circle().fill(Color(.image)))
    }
}

struct LayerTransformationModifier: ViewModifier {
    let scaleX: Double?
    let scaleY: Double?

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: scaleX ?? 1.0, y: scaleY ?? 1.0)
    }
}

struct EditFrameResizeModifier: ViewModifier {
    let edge: Edge.Set

    func body(content: Content) -> some View {
        ZStack {
            Circle()
                .fill(Color(.tint))
                .frame(width: 13, height: 13)
            content
                .frame(width: 14, height: 14)
                .padding(5)
        }
        .padding(edge, 2)
    }
}
