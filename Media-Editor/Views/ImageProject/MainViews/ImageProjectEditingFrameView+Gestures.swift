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

                layerScaleGesturePositionLocker(newPosition:
                    CGPoint(x: newX,
                            y: newY), scaleEdges: [.top],
                    newScaleY: newScale)
            }
            .updating($lastPosition) { _, lastPosition, _ in
                lastPosition = lastPosition ?? layerModel.position
            }
            .updating($lastScaleY) { _, lastScaleY, _ in
                lastScaleY = lastScaleY ?? layerModel.scaleY
            }
            .onEnded { _ in
                vm.updateLatestSnapshot()
            }
    }

    func halfPiRotationGesture(layerModel: LayerModel) -> some Gesture {
        TapGesture()
            .onEnded {
                guard let rotation = layerModel.rotation else { return }

                var rotationChange: CGFloat

                let times = abs(rotation.degrees) / 89.9
                rotationChange = copysign(-1.0, rotation.degrees) * floor(times) * 90.0 - 90.0
                withAnimation(.easeInOut(duration: 0.35)) {
                    layerModel.rotation = Angle(degrees: rotationChange)
                    vm.activeLayer?.rotation = Angle(degrees: rotationChange)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    vm.updateLatestSnapshot()
                }
            }
    }

    func rotationGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let layerCenterPoint = layerModel.position,
                      let planeCurrentPosition = vm.plane.currentPosition else { return }

                let currentDragPoint = CGPoint(x: value.location.x - planeCurrentPosition.x,
                                               y: value.location.y - planeCurrentPosition.y)

                let previousDragPoint = CGPoint(x: value.startLocation.x - planeCurrentPosition.x,
                                                y: value.startLocation.y - planeCurrentPosition.y)

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
                vm.updateLatestSnapshot()
            }
    }

    func trailingScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

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

                let newX = lastPosition.x - dragLenght * 0.5
                    * cos(CGFloat(rotation.radians))

                let newY = lastPosition.y - dragLenght * 0.5
                    * sin(CGFloat(rotation.radians))

                layerScaleGesturePositionLocker(newPosition:
                    CGPoint(x: newX,
                            y: newY), scaleEdges: [.trailing],
                    newScaleX: newScale)
            }
            .updating($lastPosition) { _, lastPosition, _ in
                lastPosition = lastPosition ?? layerModel.position
            }
            .updating($lastScaleX) { _, lastScaleX, _ in
                lastScaleX = lastScaleX ?? layerModel.scaleX
            }
            .onEnded { _ in
                vm.updateLatestSnapshot()
            }
    }

    func aspectScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

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
                vm.updateLatestSnapshot()
            }
    }

    func bottomScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

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

                let newX = lastPosition.x - dragLenght * 0.5
                    * sin(CGFloat(rotation.radians))

                let newY = lastPosition.y + dragLenght * 0.5
                    * cos(CGFloat(rotation.radians))

                layerScaleGesturePositionLocker(newPosition:
                    CGPoint(x: newX,
                            y: newY), scaleEdges: [.bottom],
                    newScaleY: newScale)
            }
            .updating($lastPosition) { _, lastPosition, _ in
                lastPosition = lastPosition ?? layerModel.position
            }
            .updating($lastScaleY) { _, lastScaleY, _ in
                lastScaleY = lastScaleY ?? layerModel.scaleY
            }
            .onEnded { _ in
                vm.updateLatestSnapshot()
            }
    }

    func moveGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard let rotation = layerModel.rotation,
                      let planeScale = vm.plane.scale else { return }

                let width = value.translation.width * cos(CGFloat(rotation.radians))
                    - value.translation.height * sin(CGFloat(rotation.radians))
                let height = value.translation.width * sin(CGFloat(rotation.radians))
                    + value.translation.height * cos(CGFloat(rotation.radians))
                vm.performLayerDragPublisher.send(CGSize(width: width / planeScale,
                                                         height: height / planeScale))
            }.onEnded { _ in
                vm.updateLatestSnapshot()
            }
    }

    func leadingScaleGesture(layerModel: LayerModel) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard let lastPosition,
                      let rotation = layerModel.rotation,
                      let layerSize = layerModel.size else { return }

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

                let newX = lastPosition.x + dragLenght * 0.5
                    * cos(CGFloat(rotation.radians))

                let newY = lastPosition.y + dragLenght * 0.5
                    * sin(CGFloat(rotation.radians))

                layerScaleGesturePositionLocker(newPosition:
                    CGPoint(x: newX,
                            y: newY), scaleEdges: [.leading],
                    newScaleX: newScale)
            }
            .updating($lastPosition) { _, lastPosition, _ in
                lastPosition = lastPosition ?? layerModel.position
            }
            .updating($lastScaleX) { _, lastScaleX, _ in
                lastScaleX = lastScaleX ?? layerModel.scaleX
            }
            .onEnded { _ in
                vm.updateLatestSnapshot()
            }
    }

    func layerScaleGesturePositionLocker(newPosition: CGPoint,
                                         scaleEdges: [Edge],
                                         newScaleX: Double? = nil,
                                         newScaleY: Double? = nil)
    {
        guard let frameRect = vm.frame.rect,
              let scaledLayerRotation = layerModel.rotation,
              let scaledLayerSize = layerModel.size,
              let scaledLayerScaleX = layerModel.scaleX,
              let scaledLayerScaleY = layerModel.scaleY else { return }

        let scaledLayerTopLeftApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .topLeft)(newPosition)
        let scaledLayerTopRightApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .topRight)(newPosition)
        let scaledLayerBottomLeftApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .bottomLeft)(newPosition)
        let scaledLayerBottomRightApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .bottomRight)(newPosition)

        let scaledLayerWidth = scaledLayerSize.width * abs(scaledLayerScaleX)
        let scaledLayerHeight = scaledLayerSize.height * abs(scaledLayerScaleY)

        var (isXChanged, isYChanged) = (false, false)
        var dragGestureTolerance = 10.0
        var (newX, newY) = (newPosition.x, newPosition.y)
        var (newScaleX, newScaleY) = (newScaleX, newScaleY)
        var touchPositionX: CGFloat?
        var touchPositionY: CGFloat?

        for otherLayer in vm.projectLayers
            where (otherLayer.positionZ ?? 0) > 0 && otherLayer != layerModel
        {
            guard let otherLayerPosition = otherLayer.position,
                  let otherLayerRotation = otherLayer.rotation,
                  let otherLayerSize = otherLayer.size,
                  let otherLayerScaleX = otherLayer.scaleX,
                  let otherLayerScaleY = otherLayer.scaleY
            else { return }

            guard scaledLayerRotation.isRightAngle, otherLayerRotation.isRightAngle else { continue }

            let otherLayerTopLeftApexPosition =
                otherLayer.rotatedApexPositionFunction(apex: .topLeft)(nil)
            let otherLayerTopRightApexPosition =
                otherLayer.rotatedApexPositionFunction(apex: .topRight)(nil)
            let otherLayerBottomLeftApexPosition =
                otherLayer.rotatedApexPositionFunction(apex: .bottomLeft)(nil)
            let otherLayerBottomRightApexPosition =
                otherLayer.rotatedApexPositionFunction(apex: .bottomRight)(nil)

            let otherLayerWidth = otherLayerSize.width * abs(otherLayerScaleX)
            let otherLayerHeight = otherLayerSize.height * abs(otherLayerScaleY)
            let scaledLayerWidth = scaledLayerSize.width * abs(scaledLayerScaleX)
            let scaledLayerHeight = scaledLayerSize.height * abs(scaledLayerScaleY)

            //                     trailing - leading
            if abs(scaledLayerTopRightApexPosition.x - otherLayerBottomLeftApexPosition.x)
                < dragGestureTolerance, scaleEdges.contains(.trailing)
            {
                if !isXChanged {
                    newScaleX = (newScaleX ?? 1.0)
                        * abs(otherLayerBottomLeftApexPosition.x - scaledLayerTopLeftApexPosition.x)
                        / scaledLayerWidth

                    let scaledLayerComponent = 0.0
                        - scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.x
                        - otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newX = scaledLayerComponent + otherLayerComponent
                    touchPositionX = otherLayerBottomLeftApexPosition.x
                }
                isXChanged = true
            }
            //                      trailing - trailing
            else if abs(scaledLayerTopRightApexPosition.x - otherLayerTopRightApexPosition.x)
                < dragGestureTolerance, scaleEdges.contains(.trailing)
            {
                if !isXChanged {
                    newScaleX = (newScaleX ?? 1.0)
                        * abs(otherLayerTopRightApexPosition.x - scaledLayerTopLeftApexPosition.x)
                        / scaledLayerWidth

                    let scaledLayerComponent = 0.0
                        - scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.x
                        + otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newX = scaledLayerComponent + otherLayerComponent
                    touchPositionX = otherLayerTopRightApexPosition.x
                }
                isXChanged = true
            }
            // leading - leading
            else if abs(scaledLayerBottomLeftApexPosition.x - otherLayerBottomLeftApexPosition.x)
                < dragGestureTolerance, scaleEdges.contains(.leading)
            {
                if !isXChanged {
                    newScaleX = (newScaleX ?? 1.0)
                        * abs(otherLayerBottomLeftApexPosition.x - scaledLayerBottomRightApexPosition.x)
                        / scaledLayerWidth
                    let scaledLayerComponent = 0.0
                        + scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.x
                        - otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newX = scaledLayerComponent + otherLayerComponent
                    touchPositionX = otherLayerBottomLeftApexPosition.x
                }
                isXChanged = true
            }
            // leading - trailing
            else if abs(scaledLayerBottomLeftApexPosition.x - otherLayerTopRightApexPosition.x)
                < dragGestureTolerance, scaleEdges.contains(.leading)
            {
                if !isXChanged {
                    newScaleX = (newScaleX ?? 1.0)
                        * abs(otherLayerTopRightApexPosition.x - scaledLayerBottomRightApexPosition.x)
                        / scaledLayerWidth
                    let scaledLayerComponent = 0.0
                        + scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.x
                        + otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newX = scaledLayerComponent + otherLayerComponent
                    touchPositionX = otherLayerTopRightApexPosition.x
                }
                isXChanged = true
            }
            // top - bottom
            if abs(scaledLayerTopLeftApexPosition.y - otherLayerBottomRightApexPosition.y)
                < dragGestureTolerance, scaleEdges.contains(.top)
            {
                if !isYChanged {
                    newScaleY = (newScaleY ?? 1.0)
                        * abs(otherLayerBottomRightApexPosition.y - scaledLayerBottomLeftApexPosition.y)
                        / scaledLayerHeight
                    let scaledLayerComponent = 0.0
                        - scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.y
                        - otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newY = scaledLayerComponent + otherLayerComponent
                    touchPositionY = otherLayerBottomRightApexPosition.y
                }
                isYChanged = true
            }
            // top - top
            else if abs(scaledLayerTopLeftApexPosition.y - otherLayerTopLeftApexPosition.y)
                < dragGestureTolerance, scaleEdges.contains(.top)
            {
                if !isYChanged {
                    newScaleY = (newScaleY ?? 1.0)
                        * abs(otherLayerTopLeftApexPosition.y - scaledLayerBottomLeftApexPosition.y)
                        / scaledLayerHeight
                    let scaledLayerComponent = 0.0
                        - scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.y
                        + otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newY = scaledLayerComponent + otherLayerComponent
                    touchPositionY = otherLayerTopLeftApexPosition.y
                }
                isYChanged = true
            }
            // bottom - bottom
            else if abs(scaledLayerBottomRightApexPosition.y - otherLayerBottomRightApexPosition.y)
                < dragGestureTolerance, scaleEdges.contains(.bottom)
            {
                if !isYChanged {
                    newScaleY = (newScaleY ?? 1.0)
                        * abs(otherLayerBottomRightApexPosition.y - scaledLayerTopRightApexPosition.y)
                        / scaledLayerHeight
                    let scaledLayerComponent = 0.0
                        + scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.y
                        - otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newY = scaledLayerComponent + otherLayerComponent
                    touchPositionY = otherLayerBottomRightApexPosition.y
                }
                isYChanged = true
            }
            // bottom - top
            else if abs(scaledLayerBottomRightApexPosition.y - otherLayerTopLeftApexPosition.y)
                < dragGestureTolerance, scaleEdges.contains(.bottom)
            {
                if !isYChanged {
                    newScaleY = (newScaleY ?? 1.0)
                        * abs(otherLayerTopLeftApexPosition.y - scaledLayerTopRightApexPosition.y)
                        / scaledLayerHeight
                    let scaledLayerComponent = 0.0
                        + scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let otherLayerComponent = otherLayerPosition.y
                        + otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                        * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    newY = scaledLayerComponent + otherLayerComponent
                    touchPositionY = otherLayerTopLeftApexPosition.y
                }
                isYChanged = true
            }
        }

        if scaledLayerRotation.isRightAngle {
            // trailing - frameTrailing
            if abs(scaledLayerTopRightApexPosition.x - frameRect.maxX) < dragGestureTolerance,
               scaleEdges.contains(.trailing)
            {
                if !isXChanged {
                    newScaleX = (newScaleX ?? 1.0)
                        * abs(frameRect.maxX - scaledLayerTopLeftApexPosition.x)
                        / scaledLayerWidth
                    let scaledLayerComponent = 0.0
                        - scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = frameRect.size.width * 0.5

                    newX = scaledLayerComponent + frameComponent
                    touchPositionX = nil
                }
                isXChanged = true
            }
            // leading - frameLeading
            else if abs(scaledLayerBottomLeftApexPosition.x - frameRect.minX) < dragGestureTolerance,
                    scaleEdges.contains(.leading)
            {
                if !isXChanged {
                    newScaleX = (newScaleX ?? 1.0)
                        * abs(frameRect.minX - scaledLayerBottomRightApexPosition.x)
                        / scaledLayerWidth

                    let scaledLayerComponent = 0.0
                        + scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = -frameRect.size.width * 0.5

                    newX = scaledLayerComponent + frameComponent
                }
                touchPositionX = nil
                isXChanged = true
            }
            // top - frameTop
            if abs(scaledLayerTopLeftApexPosition.y - frameRect.minY) < dragGestureTolerance,
               scaleEdges.contains(.top)
            {
                if !isYChanged {
                    newScaleY = (newScaleY ?? 1.0)
                        * abs(frameRect.minY - scaledLayerBottomLeftApexPosition.y)
                        / scaledLayerHeight

                    let scaledLayerComponent = 0.0
                        - scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = -frameRect.size.height * 0.5

                    newY = scaledLayerComponent + frameComponent
                }
                touchPositionY = nil
                isYChanged = true
            }
            // bottom - frameBottom
            else if abs(scaledLayerBottomRightApexPosition.y - frameRect.maxY) < dragGestureTolerance,
                    scaleEdges.contains(.bottom)
            {
                if !isYChanged {
                    newScaleY = (newScaleY ?? 1.0)
                        * abs(frameRect.maxY - scaledLayerTopRightApexPosition.y)
                        / scaledLayerHeight

                    let scaledLayerComponent = 0.0
                        + scaledLayerSize.width * abs(newScaleX ?? 1.0) * 0.5 * sin(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - scaledLayerSize.height * abs(newScaleY ?? 1.0) * 0.5 * cos(scaledLayerRotation.radians)
                        * (scaledLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = frameRect.size.height * 0.5

                    newY = scaledLayerComponent + frameComponent
                }
                touchPositionY = nil
                isYChanged = true
            }
        }

        if let newScaleX, !wasPreviousScaleGestureFrameLockedForX {
            layerModel.position?.x = newX
            layerModel.scaleX = newScaleX
        }
        if let newScaleY, !wasPreviousScaleGestureFrameLockedForY {
            layerModel.position?.y = newY
            layerModel.scaleY = newScaleY
        }

        if !isXChanged {
            wasPreviousScaleGestureFrameLockedForX = false
            vm.plane.lineXPosition = nil
        }
        else {
            if !wasPreviousScaleGestureFrameLockedForX {
                if touchPositionX == nil {
                    HapticService.shared.play(.medium)
                }
                wasPreviousScaleGestureFrameLockedForX = true
                vm.plane.lineXPosition = touchPositionX
            }
        }

        if !isYChanged {
            wasPreviousScaleGestureFrameLockedForY = false
            vm.plane.lineYPosition = nil
        }
        else {
            if !wasPreviousScaleGestureFrameLockedForY {
                if touchPositionY == nil {
                    HapticService.shared.play(.medium)
                }

                wasPreviousScaleGestureFrameLockedForY = true
                vm.plane.lineYPosition = touchPositionY
            }
        }
    }
}
