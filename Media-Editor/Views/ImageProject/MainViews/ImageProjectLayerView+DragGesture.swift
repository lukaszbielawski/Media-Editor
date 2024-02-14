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
            .onChanged { value in

                var newDraggedLayerPosition = lastPosition ?? layerModel.position ?? CGPoint()
                newDraggedLayerPosition.x += value.translation.width
                newDraggedLayerPosition.y += value.translation.height

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

                        layerModel.position?.x = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.x = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.x = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.x = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.y = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.y = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.y = draggedLayerComponent + otherLayerComponent
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

                        layerModel.position?.y = draggedLayerComponent + otherLayerComponent
                        isYChanged = true
                    }
                }

                if abs(newDraggedLayerPosition.x - frameRect.midX) < dragGestureTolerance {
                    layerModel.position?.x = frameRect.midX
                    isXChanged = true
                }
                // trailing - frameTrailing
                else if abs(draggedLayerTopRightApexPosition.x - frameRect.maxX) < dragGestureTolerance {
                    let draggedLayerComponent = 0.0
                        - draggedLayerWidth * 0.5 * cos(draggedLayerRotation.radians)
                        * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + draggedLayerHeight * 0.5 * sin(draggedLayerRotation.radians)
                        * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = frameRect.size.width * 0.5

                    layerModel.position?.x = draggedLayerComponent + frameComponent
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

                    layerModel.position?.x = draggedLayerComponent + frameComponent
                    isXChanged = true
                }

                // centerY - frameCenterY
                if abs(newDraggedLayerPosition.y - frameRect.midY) < dragGestureTolerance {
                    layerModel.position?.y = frameRect.midY
                    isYChanged = true
                }
                // top - top
                else if abs(draggedLayerTopLeftApexPosition.y - frameRect.minY) < dragGestureTolerance {
                    let draggedLayerComponent = 0.0
                        - draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                        * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        + draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                        * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = -frameRect.size.height * 0.5

                    layerModel.position?.y = draggedLayerComponent + frameComponent
                    isYChanged = true
                }
                // bottom - bottom
                else if abs(draggedLayerBottomRightApexPosition.y - frameRect.maxY) < dragGestureTolerance {
                    let draggedLayerComponent = 0.0
                        + draggedLayerWidth * 0.5 * sin(draggedLayerRotation.radians)
                        * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)
                        - draggedLayerHeight * 0.5 * cos(draggedLayerRotation.radians)
                        * (draggedLayerRotation.isBelowHalfAngle ? -1.0 : 1.0)

                    let frameComponent = frameRect.size.height * 0.5

                    layerModel.position?.y = draggedLayerComponent + frameComponent
                    isYChanged = true
                }

                if !isXChanged {
                    layerModel.position?.x = newDraggedLayerPosition.x
                    wasPreviousDragGestureFrameLockedForX = false
                } else if !wasPreviousDragGestureFrameLockedForX {
                    HapticService.shared.play(.medium)
                    wasPreviousDragGestureFrameLockedForX = true
                }

                if !isYChanged {
                    layerModel.position?.y = newDraggedLayerPosition.y
                    wasPreviousDragGestureFrameLockedForY = false
                } else if !wasPreviousDragGestureFrameLockedForY {
                    HapticService.shared.play(.medium)
                    wasPreviousDragGestureFrameLockedForY = true
                }
            }
            .updating($lastPosition) { _, startPosition, _ in
                startPosition = startPosition ?? layerModel.position
            }.onEnded { _ in
                PersistenceController.shared.saveChanges()
            }
    }
}
