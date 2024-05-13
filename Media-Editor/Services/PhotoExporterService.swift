//
//  PhotoExporterService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/02/2024.
//

import Foundation
import SwiftUI

struct PhotoExporterService {
    func resizePhoto(renderedPhoto: CGImage,
                     renderSize: RenderSizeType,
                     photoFormat: PhotoFormatType,
                     framePixelWidth: CGFloat,
                     framePixelHeight: CGFloat,
                     marginedWorkspaceWidth: CGFloat) async throws -> CGImage
    {
        return try await Task {
            let resizedFramePixelWidth: CGFloat
            let resizedFramePixelHeight: CGFloat

            if renderSize == .preview {
                let aspectRatio = framePixelWidth / framePixelHeight

                resizedFramePixelWidth = min(framePixelWidth, marginedWorkspaceWidth)
                resizedFramePixelHeight = resizedFramePixelWidth / aspectRatio
            } else {
                resizedFramePixelWidth = framePixelWidth * renderSize.sizeFactor
                resizedFramePixelHeight = framePixelHeight * renderSize.sizeFactor
            }

            guard let colorSpace = renderedPhoto.colorSpace else {
                throw PhotoExportError.colorSpace
            }

            let context = CGContext(data: nil,
                                    width: Int(resizedFramePixelWidth),
                                    height: Int(resizedFramePixelHeight),
                                    bitsPerComponent: renderedPhoto.bitsPerComponent,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: renderedPhoto.bitmapInfo.rawValue)

            context?.draw(renderedPhoto,
                          in: CGRect(
                              origin: .zero,
                              size: CGSize(width: resizedFramePixelWidth,
                                           height: resizedFramePixelHeight)
                          ))

            guard let resizedImage = context?.makeImage() else {
                throw PhotoExportError.contextResizedImageMaking
            }

            return resizedImage
        }.value
    }

    func cropLayerToImage(layer: LayerModel,
                          pixelFrameSize: CGSize,
                          pixelCropSize: CGSize,
                          pixelOffset: CGSize,
                          cropPath: Path,
                          shapePoints: CropShapeType.Points) async throws -> CGImage
    {
        return try await Task {
            guard let layerImage = layer.cgImage else { throw PhotoExportError.noCGImageInLayer }

            let customShapeOffset = CGSize(width: (shapePoints.maxX - 1.0) * pixelCropSize.width, height: (shapePoints.maxY - 1.0) * pixelCropSize.height)

            let offsetSize = CGSize(
                width: min(pixelCropSize.width * shapePoints.unitWidth - pixelFrameSize.width, 0.0) * 0.5 + abs(pixelOffset.width)
                    + customShapeOffset.width,
                height: min(pixelCropSize.height * shapePoints.unitHeight - pixelFrameSize.height, 0.0) * 0.5 + abs(pixelOffset.height)
                    + customShapeOffset.height
            )

            let contextSize = CGSize(
                width: pixelCropSize.width *
                    shapePoints.unitWidth
                    - max(0.0, offsetSize.width),

                height: pixelCropSize.height *
                    shapePoints.unitHeight
                    - max(0.0, offsetSize.height)
            )

            guard let context = CGContext(data: nil,
                                          width: Int(contextSize.width),
                                          height: Int(contextSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

            else { throw PhotoExportError.contextCreation(contextSize: .init(width: Int(contextSize.width), height: Int(contextSize.height))) }

            let bezierPath = UIBezierPath(cgPath: cropPath.cgPath)

            let croppingFrameCoverageTranslation = CGAffineTransform(
                translationX: min(0.0, max(0.0, offsetSize.width)
                    * copysign(-1.0, layer.scaleX ?? 1.0)
                    * copysign(-1.0, pixelOffset.width)),
                y: -max(0.0, max(0.0, offsetSize.height)
                    * copysign(-1.0, layer.scaleY ?? 1.0)
                    * copysign(-1.0, pixelOffset.height))
            )

            let pathCroppingFrameCoverageTranslation = CGAffineTransform(
                translationX: min(0.0, max(0.0, offsetSize.width * shapePoints.unitWidth)
                    * copysign(-1.0, pixelOffset.width)) * copysign(-1.0, layer.scaleX ?? 1.0),
                y: -min(0.0, max(0.0, offsetSize.height * shapePoints.unitHeight)
                    * copysign(-1.0, pixelOffset.height))
                    * copysign(-1.0, layer.scaleY ?? 1.0)
            )

            let shapeCoverageTranslation = CGAffineTransform(translationX: -shapePoints.minX * pixelFrameSize.width * copysign(-1.0, layer.scaleX ?? 1.0), y: shapePoints.minY * pixelFrameSize.height * copysign(-1.0, layer.scaleY ?? 1.0))

            let layerScaleTransform = CGAffineTransform(
                scaleX:
                copysign(-1.0, layer.scaleX ?? 1.0),
                y:
                -copysign(-1.0, layer.scaleY ?? 1.0)
            )

            let moveToOriginTranslation = CGAffineTransform(
                translationX:
                -contextSize.width * 0.5,
                y:
                -contextSize.height * 0.5
            )

            bezierPath.apply(
                CGAffineTransformIdentity
                    .concatenating(moveToOriginTranslation)
                    .concatenating(layerScaleTransform)
                    .concatenating(moveToOriginTranslation.inverted())
                    .concatenating(pathCroppingFrameCoverageTranslation)
                    .concatenating(shapeCoverageTranslation)
            )

            context.addPath(bezierPath.cgPath)

            context.clip()

            context.concatenate(croppingFrameCoverageTranslation)
            context.concatenate(shapeCoverageTranslation)

            context.translateBy(x: copysign(-1.0, layer.scaleX ?? 1.0) == 1.0 ? 0.0
                : -(1.0 - shapePoints.unitWidth) * pixelFrameSize.width,
                y: copysign(-1.0, layer.scaleY ?? 1.0) == 1.0 ? -(1.0 - shapePoints.unitHeight) * pixelFrameSize.height
                    : 0.0)

            context.scaleBy(x: copysign(-1.0, layer.scaleX ?? 1.0), y: copysign(-1.0, layer.scaleY ?? 1.0))

            context.translateBy(
                x: (pixelCropSize.width - pixelFrameSize.width) * 0.5 * copysign(-1.0, layer.scaleX ?? 1.0),
                y: (pixelCropSize.height - pixelFrameSize.height) * 0.5 * copysign(-1.0, layer.scaleY ?? 1.0)
            )

            context.translateBy(x: -pixelOffset.width, y: pixelOffset.height)

            context.scaleBy(x: copysign(-1.0, layer.scaleX ?? 1.0), y: copysign(-1.0, layer.scaleY ?? 1.0))

            context.draw(layerImage, in: CGRect(x: 0,
                                                y: 0,
                                                width: CGFloat(layerImage.width),
                                                height: CGFloat(layerImage.height)))

            let clippedImage = context.makeImage()

            guard let clippedImage else { throw PhotoExportError.contextImageMaking }

            return clippedImage

        }.value
    }

    func exportLayersToImage(photos: [LayerModel],
                             contextPixelSize: CGSize,
                             offsetFromCenter: CGPoint = .zero,
                             projectBackgroundColor: CGColor = Color.clear.cgColor,
                             layerBackgroundShapeStyle: ShapeStyleModel? = nil,
                             isApplyingTransforms: Bool = true) async throws -> CGImage
    {
        return try await Task {
            guard let context = CGContext(data: nil,
                                          width: Int(contextPixelSize.width),
                                          height: Int(contextPixelSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            else { throw PhotoExportError
                .contextCreation(contextSize:
                    .init(width: Int(contextPixelSize.width),
                          height: Int(contextPixelSize.height)))
            }

            context.setFillColor(projectBackgroundColor)

            context.fill(CGRect(origin: .zero, size: contextPixelSize))

            for photo in photos
                .filter({ $0.positionZ != nil && $0.positionZ! > 0 })
                .sorted(by: { $0.positionZ! < $1.positionZ! })
            {
                guard let scaleX = photo.scaleX,
                      let scaleY = photo.scaleY,
                      let rotation = photo.rotation,
                      let position = photo.position
                else { continue }

                guard let layerImage = photo.cgImage else { continue }

                context.saveGState()

                let centerTranslation =
                    CGSize(width: photo.pixelSize.width * 0.5,
                           height: photo.pixelSize.height * 0.5)

                let translationTransform = CGAffineTransform(
                    translationX: contextPixelSize.width * 0.5
                        - centerTranslation.width * scaleX
                        + position.x * photo.pixelToDigitalWidthRatio + offsetFromCenter.x,
                    y:
                    contextPixelSize.height * 0.5
                        - centerTranslation.height * scaleY
                        - position.y * photo.pixelToDigitalHeightRatio - offsetFromCenter.y
                )

                let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                let rotationTransform = CGAffineTransform(rotationAngle: -rotation.radians)

                let originTranslation = CGAffineTransform(translationX: -centerTranslation.width * scaleX,
                                                          y: -centerTranslation.height * scaleY)
                let reverseOriginTranslation = CGAffineTransform(translationX: centerTranslation.width * scaleX,
                                                                 y: +centerTranslation.height * scaleY)

                let resultTransform = CGAffineTransform.identity
                    .concatenating(scaleTransform)
                    .concatenating(originTranslation)
                    .concatenating(rotationTransform)
                    .concatenating(reverseOriginTranslation)
                    .concatenating(translationTransform)

                if isApplyingTransforms {
                    context.concatenate(resultTransform)
                }

                let shapeStyle = layerBackgroundShapeStyle?.shapeStyle
                let shapeStyleCG = layerBackgroundShapeStyle?.shapeStyleCG

                if layerBackgroundShapeStyle != nil {
                    if let color = shapeStyle as? Color {
                        context.setFillColor(color.cgColor)
                    } else if let cgLinearGradient = shapeStyleCG as? CGLinearGradient,
                              let cgGradient = cgLinearGradient.cgGradient
                    {
                        let startPoint = cgLinearGradient.startPoint
                        let endPoint = cgLinearGradient.endPoint

                        let startX = contextPixelSize.width * startPoint.x
                        let startY = contextPixelSize.height * startPoint.y
                        let endX = contextPixelSize.width * endPoint.x
                        let endY = contextPixelSize.height * endPoint.y

                        let start = CGPoint(x: startX, y: startY)
                        let end = CGPoint(x: endX, y: endY)

                        context.drawLinearGradient(cgGradient,
                                                   start: start,
                                                   end: end,
                                                   options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
                    }
                    context.fill(CGRect(origin: .zero, size: .init(width: photo.pixelSize.width,
                                                                   height: photo.pixelSize.height)))
                }

                context.draw(layerImage, in:
                    CGRect(x: 0,
                           y: 0,
                           width: photo.pixelSize.width,
                           height: photo.pixelSize.height))

                context.restoreGState()
            }

            guard let resultCGImage = context.makeImage() else { throw PhotoExportError.contextImageMaking }

            return resultCGImage
        }.value
    }

    func renderImageFromDrawings(
        from drawings: [DrawingModel],
        on layer: LayerModel,
        frameSize: CGSize,
        pixelFrameSize: CGSize
    ) async throws -> CGImage {
        return try await Task {
            guard let context = CGContext(data: nil,
                                          width: Int(pixelFrameSize.width),
                                          height: Int(pixelFrameSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

            else { throw PhotoExportError.contextCreation(contextSize: .init(width: Int(pixelFrameSize.width), height: Int(pixelFrameSize.height))) }

            guard let layerImage = layer.cgImage, let layerScaleX = layer.scaleX, let layerScaleY = layer.scaleY else { throw PhotoExportError.noCGImageInLayer }

            context.draw(layerImage, in: CGRect(x: 0,
                                                y: 0,
                                                width: CGFloat(pixelFrameSize.width),
                                                height: CGFloat(pixelFrameSize.height)))

            let pixelRatioTransform = CGAffineTransform(scaleX: pixelFrameSize.width / frameSize.width, y: pixelFrameSize.height / frameSize.height)

            context.translateBy(x: 0, y: pixelFrameSize.height)
            context.scaleBy(x: 1, y: -1)
            context.saveGState()
            context.scaleBy(x: copysign(-1.0, layer.scaleX ?? 1.0), y: copysign(-1.0, layer.scaleY ?? 1.0))
            context.translateBy(x: min(copysign(-1.0, layer.scaleX ?? 1.0), 0) * pixelFrameSize.width,
                                y: min(copysign(-1.0, layer.scaleY ?? 1.0), 0) * pixelFrameSize.height)

            for drawing in drawings {
                var path = Path()

                drawing.setupPath(&path)

                context.addPath(path.applying(pixelRatioTransform).cgPath)

                context.saveGState()
                context.scaleBy(x: 1.0 / abs(layer.scaleX ?? 1.0), y: 1.0 / abs(layer.scaleY ?? 1.0))
                defer { context.restoreGState() }

                if drawing.currentPencilType == .eraser {
                    context.setBlendMode(.destinationOut)
                }

                let lineWidthTransformed = CGFloat(drawing.currentPencilSize) * sqrt(pixelRatioTransform.a * pixelRatioTransform.d)
                    * sqrt(abs(layer.scaleX ?? 1.0) * abs(layer.scaleY ?? 1.0))

                context.setAllowsAntialiasing(true)
                context.setLineWidth(lineWidthTransformed)
                context.setLineCap(.round)

                let pencilStyle = drawing.currentPencilStyle.shapeStyle
                let pencilStyleCG = drawing.currentPencilStyle.shapeStyleCG

                if drawing.currentPencilType == .eraser {
                    context.setStrokeColor(UIColor.black.cgColor)
                } else {
                    if let pencilStyle = pencilStyle as? Color {
                        context.setStrokeColor(UIColor(pencilStyle).cgColor)
                    } else if let cgLinearGradient = pencilStyleCG as? CGLinearGradient,
                              let cgGradient = cgLinearGradient.cgGradient
                    {
                        context.saveGState()
                        defer { context.restoreGState() }

                        let uiPath = UIBezierPath(cgPath: path.applying(pixelRatioTransform).cgPath)

                        uiPath.addClip()

                        context.replacePathWithStrokedPath()
                        context.clip()

                        let startPoint = cgLinearGradient.startPoint
                        let endPoint = cgLinearGradient.endPoint

                        let startX = pixelFrameSize.width * startPoint.x
                        let startY = pixelFrameSize.height * startPoint.y
                        let endX = pixelFrameSize.width * endPoint.x
                        let endY = pixelFrameSize.height * endPoint.y

                        let start = CGPoint(x: startX, y: startY)
                        let end = CGPoint(x: endX, y: endY)

                        context.scaleBy(x: abs(layer.scaleX ?? 1.0), y: abs(layer.scaleY ?? 1.0))

                        context.drawLinearGradient(cgGradient,
                                                   start: start,
                                                   end: end,
                                                   options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
                    }
                }

                context.strokePath()

                if drawing.currentPencilType == .eraser {
                    context.setBlendMode(.normal)
                    context.setStrokeColor(UIColor.clear.cgColor)
                }
            }

            context.restoreGState()

            let clippedImage = context.makeImage()

            guard let clippedImage else { throw PhotoExportError.contextImageMaking }

            return clippedImage

        }.value
    }

    func renderImageAfterMagicWandAction(layer: LayerModel,
                                         layerImage: CGImage,
                                         magicWandModel: MagicWandModel,
                                         mask: UnsafePointer<Bool>) async throws -> CGImage
    {
        return try await Task(priority: .userInitiated) {
            let contextWidth = Int(layer.pixelSize.width)
            let contextHeight = Int(layer.pixelSize.height)

            guard let context = CGContext(data: nil,
                                          width: contextWidth,
                                          height: contextHeight,
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            else {
                throw PhotoExportError.contextCreation(contextSize: .init(width: contextWidth, height: contextHeight))
            }

            context.draw(layerImage, in: CGRect(x: 0,
                                                y: 0,
                                                width: contextWidth,
                                                height: contextHeight))

            if magicWandModel.magicWandType == .magicWand {
                context.setBlendMode(.destinationOut)
                context.setFillColor(UIColor.white.cgColor)
            } else if magicWandModel.magicWandType == .bucketFill {
                let shapeStyle = magicWandModel.currentBucketFillShapeStyle.shapeStyle
                let shapeStyleCG = magicWandModel.currentBucketFillShapeStyle.shapeStyleCG

                if let color = shapeStyle as? Color {
                    context.setFillColor(color.cgColor)
                } else if let cgLinearGradient = shapeStyleCG as? CGLinearGradient,
                          let cgGradient = cgLinearGradient.cgGradient
                {
                    let startPoint = cgLinearGradient.startPoint
                    let endPoint = cgLinearGradient.endPoint

                    let startX = CGFloat(contextWidth) * startPoint.x
                    let startY = CGFloat(contextHeight) * startPoint.y
                    let endX = CGFloat(contextWidth) * endPoint.x
                    let endY = CGFloat(contextHeight) * endPoint.y

                    let start = CGPoint(x: startX, y: startY)
                    let end = CGPoint(x: endX, y: endY)

                    context.drawLinearGradient(cgGradient,
                                               start: start,
                                               end: end,
                                               options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
                }
//                context.fill(CGRect(origin: .zero, size: .init(width: contextWidth,
//                                                               height: contextHeight)))
            }

            for y in 0 ..< contextHeight {
                for x in 0 ..< contextWidth {
                    let index = y * contextWidth + x
                    if mask[index] {
                        context.fill(CGRect(x: x, y: contextHeight - y - 1, width: 1, height: 1))
                    }
                }
            }

            guard let renderedImage = context.makeImage() else {
                throw PhotoExportError.contextImageMaking
            }

            return renderedImage
        }.value
    }

    func performMagicWandAction(tapPosition: CGPoint,
                                layer: LayerModel,
                                layerImage: CGImage,
                                magicWandModel: MagicWandModel) async throws -> CGImage
    {
        let tappedX = Int(min(layer.pixelSize.width - 1, max(0.0, round(tapPosition.x * layer.pixelToDigitalWidthRatio))))
        let tappedY = Int(min(layer.pixelSize.height - 1, max(0.0, round(tapPosition.y * layer.pixelToDigitalHeightRatio))))

        let width = layerImage.width
        let height = layerImage.height

        let scaledX = copysign(-1.0, layer.scaleX ?? 1.0) == 1.0 ? tappedX : width - tappedX
        let scaledY = copysign(-1.0, layer.scaleY ?? 1.0) == 1.0 ? tappedY : height - tappedY

        let tappedPixel = Pixel(x: scaledX, y: scaledY)

        guard let dataProvider = layerImage.dataProvider,
              let data = dataProvider.data,
              let imageData = CFDataGetBytePtr(data)
        else {
            throw PhotoExportError.dataRetrieving
        }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let tappedPixelIndex = width * tappedPixel.y + tappedPixel.x
        let tappedPixelIndexForComponents = tappedPixelIndex * bytesPerPixel

        let initialPixelColor = getPixelColor(tappedPixelIndexForComponents, bytesPerPixel, bytesPerRow, imageData)

        guard let initialColorComponents = initialPixelColor.components else {
            throw PhotoExportError.dataRetrieving
        }

        let matchingPixelsPointer = floodFillForMatchingPixels(
            initialPixelIndex: tappedPixelIndex,
            referenceColorComponents: initialColorComponents,
            tolerance: magicWandModel.tolerance,
            width, height, bytesPerPixel, bytesPerRow, imageData
        )

        let resultImage = try await renderImageAfterMagicWandAction(layer: layer, layerImage: layerImage, magicWandModel: magicWandModel, mask: matchingPixelsPointer)

        return resultImage
    }

    private func getPixelColor(_ pixelComponentIndex: Int,
                               _ bytesPerPixel: Int,
                               _ bytesPerRow: Int,
                               _ imageData: UnsafePointer<UInt8>) -> CGColor
    {
        let red = CGFloat(imageData[pixelComponentIndex]) / 255.0
        let green = CGFloat(imageData[pixelComponentIndex + 1]) / 255.0
        let blue = CGFloat(imageData[pixelComponentIndex + 2]) / 255.0
        let alpha = CGFloat(imageData[pixelComponentIndex + 3]) / 255.0

        return CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    private func isColorSimilar(colorToCheck: CGColor, referenceColorComponents: [CGFloat], tolerance: CGFloat) -> Bool {
        guard let colorToCheckComponents = colorToCheck.components else { return false }

        for index in 0 ... 2 {
            if abs(colorToCheckComponents[index] - referenceColorComponents[index]) > tolerance {
                return false
            }
        }
        return true
    }

    private func floodFillForMatchingPixels(initialPixelIndex: Int,
                                            referenceColorComponents: [CGFloat],
                                            tolerance: CGFloat,
                                            _ width: Int,
                                            _ height: Int,
                                            _ bytesPerPixel: Int,
                                            _ bytesPerRow: Int,
                                            _ imageData: UnsafePointer<UInt8>)
        -> UnsafePointer<Bool>
    {
        let totalSize = width * height * MemoryLayout<Bool>.stride
        var visitedPixelsPointer = UnsafeMutablePointer<Bool>.allocate(capacity: totalSize)
        var matchingPixelsPointer = UnsafeMutablePointer<Bool>.allocate(capacity: totalSize)

        var pixelToVisitStack = [initialPixelIndex]
        visitedPixelsPointer[initialPixelIndex] = true

        while !pixelToVisitStack.isEmpty {
            let currentPixelIndex = pixelToVisitStack.removeLast()

            let currentPixelIndexForComponents = currentPixelIndex * bytesPerPixel

            let currentPixelColor = getPixelColor(currentPixelIndexForComponents, bytesPerPixel, bytesPerRow, imageData)

            let isColorSimilar = isColorSimilar(colorToCheck: currentPixelColor,
                                                referenceColorComponents: referenceColorComponents,
                                                tolerance: tolerance)

            guard isColorSimilar else { continue }

            matchingPixelsPointer[currentPixelIndex] = true

            let leftPixelIndex = max(0, currentPixelIndex - 1)
            let rightPixelIndex = min(width * height - 1, currentPixelIndex + 1)
            let topPixelIndex = max(0, currentPixelIndex - width)
            let bottomPixelIndex = min(width * height - 1, currentPixelIndex + width)

            let pixelIndices = [leftPixelIndex, rightPixelIndex, topPixelIndex, bottomPixelIndex]

            for index in pixelIndices where !visitedPixelsPointer[index] {
                visitedPixelsPointer[index] = true
                pixelToVisitStack.append(index)
            }
        }
        return UnsafePointer<Bool>(matchingPixelsPointer)
    }

    func renderTextLayer(textModelEntity: TextModelEntity) async throws -> CGImage {
        return try await Task {
            let text = textModelEntity.text
            guard let font = UIFont(name: textModelEntity.fontName,
                                    size: CGFloat(textModelEntity.fontSize.doubleValue * 1.08))
            else { throw PhotoExportError.fontCreating }
            let borderSize = textModelEntity.borderSize.intValue
            let textColor = UIColor(Color(hex: textModelEntity.textColorHex))
            let borderColor = UIColor(Color(hex: textModelEntity.borderColorHex))

            let attributes = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.strokeColor: borderColor,
                NSAttributedString.Key.strokeWidth: -borderSize,
            ]

            let textWidth = text.size(withAttributes: attributes).width
            let textHeight = text.size(withAttributes: attributes).height
            let curveAngle = Angle(degrees: textModelEntity.curveDegrees.doubleValue)

            let curveFactor: Double = { (x: Double) in
                if x <= 0.5 {
                    return 30.0
                } else {
                    return 0.0267
                        * tan((x * 0.5 * .pi / 180.0) * 0.5 + .pi * 0.5)
                }

            }(abs(curveAngle.degrees))

            let radius = ((textHeight + textWidth * 6.0) * curveFactor)
                * copysign(-1.0, curveAngle.radians)

            let newWidth =
                max(textWidth * pow(abs(cos(curveAngle.radians * 0.5)), 1 / 2),
                    2.0 * abs(radius) * sin(curveAngle.radians * 0.5) * sin(curveAngle.radians * 0.5)
                        + textHeight) + textHeight * 0.25

            let heightFactor = pow(abs(cos(curveAngle.radians * 0.5 - .pi * 0.5)), 1 / 2) * (2.0 * abs(radius) * sin(curveAngle.radians * 0.5) * sin(curveAngle.radians * 0.5))

            let newHeight =
                heightFactor + textHeight

            let size = CGSize(
                width: newWidth,
                height: newHeight
            )

            guard let context = CGContext(data: nil,
                                          width: Int(size.width),
                                          height: Int(size.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            else { throw PhotoExportError.contextCreation(contextSize:
                .init(width: Int(size.width),
                      height: Int(size.height))) }

            context.translateBy(x: size.width / 2, y: size.height / 2)

            let characters: [String] = text.map { String($0) }
            let textLenght = characters.count

            context.translateBy(x: 0, y: -radius + heightFactor * 0.5 * copysign(-1.0, -curveAngle.radians))

            var arcs: [CGFloat] = []

            for i in 0 ..< textLenght {
                arcs += [chordToArc(chord: characters[i].size(withAttributes: attributes).width, radius: radius)]
            }

            let totalArc = arcs.reduce(0.0) { $0 + $1 }

            var thetaI = .pi * 0.5 + totalArc * 0.5

            for i in 0 ..< textLenght {
                thetaI -= arcs[i] * 0.5
                centreText(context: context,
                           text: characters[i],
                           radius: radius,
                           curve: thetaI,
                           attributes: attributes,
                           slantAngle: thetaI - .pi / 2)
                thetaI -= arcs[i] * 0.5
            }

            guard let resultCGImage = context.makeImage() else { throw PhotoExportError.contextImageMaking }

            let croppedImage = resultCGImage

            return croppedImage
        }.value
    }

    private func chordToArc(chord: CGFloat, radius: CGFloat) -> CGFloat {
        return 2 * asin(chord / (2 * radius))
    }

    private func getRadiusForText(text: String, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let smallestWidthOrHeight = min(text.size(withAttributes: attributes).height, text.size(withAttributes: attributes).width)
        let heightOfFont = text.size(withAttributes: attributes).height
        let radius = (smallestWidthOrHeight / 2) - heightOfFont + 5
        return radius
    }

    private func centreText(context: CGContext,
                            text: String,
                            radius: CGFloat,
                            curve: CGFloat,
                            attributes: [NSAttributedString.Key: Any],
                            slantAngle: CGFloat)
    {
        context.saveGState()
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: radius * cos(curve), y: -(radius * sin(curve)))
        context.rotate(by: -slantAngle)
        let offset = text.size(withAttributes: attributes)
        context.translateBy(x: -offset.width / 2, y: -offset.height / 2)
        UIGraphicsPushContext(context)
        text.draw(at: .zero, withAttributes: attributes)
        context.restoreGState()
    }
}
