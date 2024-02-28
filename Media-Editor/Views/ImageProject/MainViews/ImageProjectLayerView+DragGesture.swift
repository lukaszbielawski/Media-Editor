//
//  ImageProjectLayerView+DragGesture.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 14/02/2024.
//

import SwiftUI

extension ImageProjectLayerView {
    var layerDragGesture: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onChanged {
                layerDragGestureFunction($0.translation)
            }
            .updating($lastPosition) { _, startPosition, _ in
                startPosition = startPosition ?? layerModel.position
            }.onEnded { _ in
                vm.updateLatestSnapshot()
            }
    }

    func layerDragGestureFunction(_ translation: CGSize) {
        var newDraggedLayerPosition = lastPosition ?? layerModel.position ?? CGPoint()
        newDraggedLayerPosition.x += translation.width
        newDraggedLayerPosition.y += translation.height

        guard let frameRect = vm.frame.rect,
              let draggedLayerRotation = layerModel.rotation,
              let draggedLayerSize = layerModel.size,
              let draggedLayerScaleX = layerModel.scaleX,
              let draggedLayerScaleY = layerModel.scaleY else { return }

        let draggedLayerTopLeftApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .topLeft)(newDraggedLayerPosition)
        let draggedLayerTopRightApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .topRight)(newDraggedLayerPosition)
        let draggedLayerBottomLeftApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .bottomLeft)(newDraggedLayerPosition)
        let draggedLayerBottomRightApexPosition =
            layerModel.rotatedApexPositionFunction(apex: .bottomRight)(newDraggedLayerPosition)

        let draggedLayerWidth = draggedLayerSize.width * abs(draggedLayerScaleX)
        let draggedLayerHeight = draggedLayerSize.height * abs(draggedLayerScaleY)

        var (isXChanged, isYChanged) = (false, false)
        var (newX, newY) = (newDraggedLayerPosition.x, newDraggedLayerPosition.y)
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

            guard draggedLayerRotation.isRightAngle, otherLayerRotation.isRightAngle else { continue }

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
            let draggedLayerWidth = draggedLayerSize.width * abs(draggedLayerScaleX)
            let draggedLayerHeight = draggedLayerSize.height * abs(draggedLayerScaleY)

//                     trailing - leading
            if abs(draggedLayerTopRightApexPosition.x - otherLayerBottomLeftApexPosition.x)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    - draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.x
                    - otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newX = draggedLayerComponent + otherLayerComponent
                touchPositionX = otherLayerBottomLeftApexPosition.x
                isXChanged = true
            }
//                      trailing - trailing
            else if abs(draggedLayerTopRightApexPosition.x - otherLayerTopRightApexPosition.x)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    - draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.x
                    + otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newX = draggedLayerComponent + otherLayerComponent
                touchPositionX = otherLayerTopRightApexPosition.x
                isXChanged = true
            }
            // leading - leading
            else if abs(draggedLayerBottomLeftApexPosition.x - otherLayerBottomLeftApexPosition.x)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    + draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.x
                    - otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newX = draggedLayerComponent + otherLayerComponent
                touchPositionX = otherLayerBottomLeftApexPosition.x
                isXChanged = true
            }
            // leading - trailing
            else if abs(draggedLayerBottomLeftApexPosition.x - otherLayerTopRightApexPosition.x)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    + draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.x
                    + otherLayerWidth * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - otherLayerHeight * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newX = draggedLayerComponent + otherLayerComponent
                touchPositionX = otherLayerTopRightApexPosition.x
                isXChanged = true
            }
            // top - bottom
            if abs(draggedLayerTopLeftApexPosition.y - otherLayerBottomRightApexPosition.y)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    - draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.y
                    - otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newY = draggedLayerComponent + otherLayerComponent
                touchPositionY = otherLayerBottomRightApexPosition.y
                isYChanged = true
            }
            // top - top
            else if abs(draggedLayerTopLeftApexPosition.y - otherLayerTopLeftApexPosition.y)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    - draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.y
                    + otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newY = draggedLayerComponent + otherLayerComponent
                touchPositionY = otherLayerTopLeftApexPosition.y
                isYChanged = true
            }
            // bottom - bottom
            else if abs(draggedLayerBottomRightApexPosition.y - otherLayerBottomRightApexPosition.y)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    + draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.y
                    - otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newY = draggedLayerComponent + otherLayerComponent
                touchPositionY = otherLayerBottomRightApexPosition.y
                isYChanged = true
            }
            // bottom - top
            else if abs(draggedLayerBottomRightApexPosition.y - otherLayerTopLeftApexPosition.y)
                < dragGestureTolerance
            {
                let draggedLayerComponent = 0.0
                    + draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let otherLayerComponent = otherLayerPosition.y
                    + otherLayerWidth * 0.5 * sin(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - otherLayerHeight * 0.5 * cos(otherLayerRotation.radians)
                    * (otherLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                newY = draggedLayerComponent + otherLayerComponent
                touchPositionY = otherLayerTopLeftApexPosition.y
                isYChanged = true
            }
        }

        // centerX - frameCenterX
        if abs(newDraggedLayerPosition.x - frameRect.midX) < dragGestureTolerance {
            newX = frameRect.midX
            isXChanged = true
            touchPositionX = frameRect.midX
        }
        // centerY - frameCenterY
        if abs(newDraggedLayerPosition.y - frameRect.midY) < dragGestureTolerance {
            newY = frameRect.midY
            isYChanged = true
            touchPositionY = frameRect.midY
        }

        if draggedLayerRotation.isRightAngle {
            // trailing - frameTrailing
            if abs(draggedLayerTopRightApexPosition.x - frameRect.maxX) < dragGestureTolerance {
                let draggedLayerComponent = 0.0
                    - draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let frameComponent = frameRect.size.width * 0.5

                newX = draggedLayerComponent + frameComponent
                touchPositionX = nil
                isXChanged = true
            }
            // leading - frameLeading
            else if abs(draggedLayerBottomLeftApexPosition.x - frameRect.minX) < dragGestureTolerance {
                let draggedLayerComponent = 0.0
                    + draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let frameComponent = -frameRect.size.width * 0.5

                newX = draggedLayerComponent + frameComponent
                touchPositionX = nil
                isXChanged = true
            }

            // top - frameTop
            if abs(draggedLayerTopLeftApexPosition.y - frameRect.minY) < dragGestureTolerance {
                let draggedLayerComponent = 0.0
                    - draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    + draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let frameComponent = -frameRect.size.height * 0.5

                newY = draggedLayerComponent + frameComponent
                touchPositionY = nil
                isYChanged = true
            }
            // bottom - frameBottom
            else if abs(draggedLayerBottomRightApexPosition.y - frameRect.maxY) < dragGestureTolerance {
                let draggedLayerComponent = 0.0
                    + draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                    - draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                    * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                let frameComponent = frameRect.size.height * 0.5

                newY = draggedLayerComponent + frameComponent
                touchPositionY = nil
                isYChanged = true
            }
        }
        if !isXChanged {
            wasPreviousDragGestureFrameLockedForX = false
            vm.plane.lineXPosition = nil
        }
        else {
            if !wasPreviousDragGestureFrameLockedForX {
                if touchPositionX == nil {
                    HapticService.shared.play(.medium)
                }
                wasPreviousDragGestureFrameLockedForX = true
            }
            vm.plane.lineXPosition = touchPositionX
        }

        if !isYChanged {
            wasPreviousDragGestureFrameLockedForY = false
            vm.plane.lineYPosition = nil
        }
        else {
            if !wasPreviousDragGestureFrameLockedForY {
                if touchPositionY == nil {
                    HapticService.shared.play(.medium)
                }

                wasPreviousDragGestureFrameLockedForY = true
            }

            vm.plane.lineYPosition = touchPositionY
        }

        layerModel.position = CGPoint(x: newX, y: newY)
    }
}
