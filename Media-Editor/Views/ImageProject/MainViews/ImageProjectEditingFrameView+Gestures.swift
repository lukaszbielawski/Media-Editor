//
//  ImageProjectEditingFrameView+Gestures.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 12/02/2024.
//

import SwiftUI

extension ImageProjectEditingFrameView {
    func deleteGesture(layerModel: LayerModel) -> some Gesture {
        TapGesture()
            .onEnded {
                vm.layerToDelete = layerModel
                vm.tools.isDeleteImageAlertPresented = true
            }
    }

    func topScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let dragVector = CGVector(dx: (value.location.x - value.startLocation.x) / (vm.plane.scale ?? 1.0),
                                          dy: (value.location.y - value.startLocation.y) / (vm.plane.scale ?? 1.0))

                let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                let angleBetweenTopEdgeAndDragVector = dragVectorAngle + rotation

                let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                    sin(CGFloat(angleBetweenTopEdgeAndDragVector.radians))

                let newScale = (lastScaleY ?? 1.0) + dragLenght / layerSize.height
                    * copysign(-1.0, layerModel.scaleY ?? 1.0)

                guard abs(layerSize.height * newScale) > vm.plane.minDimension,
                      newScale * (layerModel.scaleY ?? 1.0) > 0.0 else { return }

                let newX = lastPosition.x + dragLenght * 0.5
                    * sin(CGFloat(rotation.radians))

                let newY = lastPosition.y - dragLenght * 0.5
                    * cos(CGFloat(rotation.radians))

                DispatchQueue.main.async {
                    layerModel.scaleY = newScale
                    layerModel.position =
                        CGPoint(x: newX,
                                y: newY)
                }
            }
            .updating($lastPosition) { _, lastPosition, _ in
                lastPosition = lastPosition ?? layerModel.position
            }
            .updating($lastScaleY) { _, lastScaleY, _ in
                lastScaleY = lastScaleY ?? layerModel.scaleY
            }
            .onEnded { _ in
                gestureEnded = true
                PersistenceController.shared.saveChanges()
            }
    }

    func halfPiRotationGesture(layerModel: LayerModel) -> some Gesture {
        TapGesture()
            .onEnded {
                guard let rotation = layerModel.rotation else { return }

                vm.updateUndoLayers()

                var rotationChange: CGFloat

                let times = abs(rotation.degrees) / 89.9
                rotationChange = copysign(-1.0, rotation.degrees) * floor(times) * 90.0 - 90.0
                print(rotationChange)
                withAnimation(.easeInOut(duration: 0.35)) {
                    layerModel.rotation = Angle(degrees: rotationChange)
                    vm.activeLayer?.rotation = Angle(degrees: rotationChange)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    PersistenceController.shared.saveChanges()
                }
            }
    }

    func rotationGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let layerCenterPoint = layerModel.position,
                      let planeCurrentPosition = vm.plane.currentPosition else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let currentDragPoint = CGPoint(x: value.location.x - planeCurrentPosition.x,
                                               y: value.location.y - planeCurrentPosition.y)

                let previousDragPoint = CGPoint(x: value.startLocation.x - planeCurrentPosition.x,
                                                y: value.startLocation.y - planeCurrentPosition.y)

                print("plane current", planeCurrentPosition)

                print("current drag point", currentDragPoint)

                let currentAngle =
                    Angle(radians: atan2(currentDragPoint.x - layerCenterPoint.x,
                                         currentDragPoint.y - layerCenterPoint.y))
                let previousAngle =
                    Angle(radians: atan2(previousDragPoint.x - layerCenterPoint.x,
                                         previousDragPoint.y - layerCenterPoint.y))

                let angleDiff = currentAngle - previousAngle

                let newAngle = (lastAngle ?? layerModel.rotation ?? .zero) - angleDiff

                DispatchQueue.main.async {
                    layerModel.rotation = newAngle
                }
            }
            .updating($lastAngle) { _, lastAngle, _ in
                lastAngle = lastAngle ?? layerModel.rotation
            }
            .onEnded { _ in
                gestureEnded = true
                PersistenceController.shared.saveChanges()
            }
    }

    func trailingScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let dragVector = CGVector(dx: (value.location.x - value.startLocation.x) / (vm.plane.scale ?? 1.0),
                                          dy: (value.location.y - value.startLocation.y) / (vm.plane.scale ?? 1.0))

                let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                let angleBetweenTrailingEdgeAndDragVector =
                    dragVectorAngle + rotation + Angle(radians: .pi * 1.5)

                let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                    sin(CGFloat(angleBetweenTrailingEdgeAndDragVector.radians))

                let newScale = (lastScaleX ?? 1.0) - dragLenght / layerSize.width
                    * copysign(-1.0, layerModel.scaleX ?? 1.0)

                guard abs(layerSize.width * newScale) > vm.plane.minDimension,
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
                gestureEnded = true
                PersistenceController.shared.saveChanges()
            }
    }

    func aspectScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let dragVector = CGVector(dx: (value.location.x - value.startLocation.x) / (vm.plane.scale ?? 1.0),
                                          dy: (value.location.y - value.startLocation.y) / (vm.plane.scale ?? 1.0))

                let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))

                let angleBetweenTrailingEdgeAndDragVector =
                    dragVectorAngle + rotation + Angle(radians: .pi * 1.5)
                let angleBetweenBottomEdgeAndDragVector =
                    dragVectorAngle + rotation + Angle(radians: .pi)

                var dragWidth = hypot(dragVector.dx, dragVector.dy) *
                    sin(CGFloat(angleBetweenTrailingEdgeAndDragVector.radians))
                var dragHeight = hypot(dragVector.dx, dragVector.dy) *
                    sin(CGFloat(angleBetweenBottomEdgeAndDragVector.radians))

                let aspectRatio =
                    abs((lastScaleX ?? 1.0) * layerSize.width) /
                    abs((lastScaleY ?? 1.0) * layerSize.height)

                dragWidth = -dragHeight * aspectRatio
                dragHeight = -dragWidth / aspectRatio

                let displacementVectorDx = -dragWidth * 0.5
                    * cos(CGFloat(rotation.radians))
                    - dragHeight * 0.5 * sin(CGFloat(rotation.radians))

                let displacementVectorDy = -dragWidth * 0.5
                    * sin(CGFloat(rotation.radians))
                    + dragHeight * 0.5 * cos(CGFloat(rotation.radians))

                let displacementVector = CGVector(
                    dx: displacementVectorDx,
                    dy: displacementVectorDy)

                let newScaleX = (lastScaleX ?? 1.0) - dragWidth / layerSize.width
                    * copysign(-1.0, layerModel.scaleX ?? 1.0)
                let newScaleY = (lastScaleY ?? 1.0) + dragHeight / layerSize.height
                    * copysign(-1.0, layerModel.scaleY ?? 1.0)

                let newX = lastPosition.x + displacementVector.dx
                let newY = lastPosition.y + displacementVector.dy

                guard abs(layerSize.width * newScaleX) > vm.plane.minDimension,
                      abs(layerSize.height * newScaleY) > vm.plane.minDimension,
                      newScaleX * (layerModel.scaleX ?? 1.0) > 0.0,
                      newScaleY * (layerModel.scaleY ?? 1.0) > 0.0 else { return }

                DispatchQueue.main.async {
                    layerModel.scaleX = newScaleX
                    layerModel.scaleY = newScaleY
                    layerModel.position =
                        CGPoint(x: newX, y: newY)
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
                gestureEnded = true
                PersistenceController.shared.saveChanges()
            }
    }

    func bottomScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let dragVector = CGVector(dx: (value.location.x - value.startLocation.x) / (vm.plane.scale ?? 1.0),
                                          dy: (value.location.y - value.startLocation.y) / (vm.plane.scale ?? 1.0))

                let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                let angleBetweenBottomEdgeAndDragVector =
                    dragVectorAngle + rotation + Angle(radians: .pi)

                let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                    sin(CGFloat(angleBetweenBottomEdgeAndDragVector.radians))

                let newScale = (lastScaleY ?? 1.0) + dragLenght / layerSize.height
                    * copysign(-1.0, layerModel.scaleY ?? 1.0)

                guard abs(layerSize.height * newScale) > vm.plane.minDimension,
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
                gestureEnded = true
                PersistenceController.shared.saveChanges()
            }
    }

    func moveGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard let rotation = layerModel.rotation,
                      let planeScale = vm.plane.scale else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let width = value.translation.width * cos(CGFloat(rotation.radians))
                    - value.translation.height * sin(CGFloat(rotation.radians))
                let height = value.translation.width * sin(CGFloat(rotation.radians))
                    + value.translation.height * cos(CGFloat(rotation.radians))
                vm.performLayerDragPublisher.send(CGSize(width: width / planeScale,
                                                         height: height / planeScale))
            }.onEnded { _ in
                gestureEnded = true
            }
    }

    func leadingScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

                if gestureEnded {
                    vm.updateUndoLayers()
                    gestureEnded = false
                }

                let dragVector = CGVector(dx: (value.location.x - value.startLocation.x) / (vm.plane.scale ?? 1.0),
                                          dy: (value.location.y - value.startLocation.y) / (vm.plane.scale ?? 1.0))

                let dragVectorAngle = Angle(radians: -atan2(dragVector.dy, dragVector.dx))
                let angleBetweenLeadingEdgeAndDragVector =
                    dragVectorAngle + rotation + Angle(radians: .pi * 0.5)

                let dragLenght = hypot(dragVector.dx, dragVector.dy) *
                    sin(CGFloat(angleBetweenLeadingEdgeAndDragVector.radians))

                let newScale = (lastScaleX ?? 1.0) - dragLenght / layerSize.width
                    * copysign(-1.0, layerModel.scaleX ?? 1.0)

                guard abs(layerSize.width * newScale) > vm.plane.minDimension,
                      newScale * (layerModel.scaleX ?? 1.0) > 0.0 else { return }

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
                gestureEnded = true
                PersistenceController.shared.saveChanges()
            }
    }
}
