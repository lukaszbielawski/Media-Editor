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

            guard let context = CGContext(data: nil,
                                          width: Int(resizedFramePixelWidth),
                                          height: Int(resizedFramePixelHeight),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else {
                throw PhotoExportError.contextCreation(contextSize: .init(width: CGFloat(resizedFramePixelWidth),
                                                                          height: CGFloat(resizedFramePixelHeight)))
            }

            context.draw(renderedPhoto,
                         in: CGRect(
                             origin: .zero,
                             size: CGSize(width: resizedFramePixelWidth,
                                          height: resizedFramePixelHeight)
                         ))

            guard let resizedImage = context.makeImage() else {
                throw PhotoExportError.contextResizedImageMaking
            }

            return resizedImage
        }.value
    }

    private func renderResizedPhoto(image: CGImage, renderSizeType: RenderSizeType) throws -> CGImage {
        let resizedWidth = Int(image.width) / renderSizeType.sizeDividend
        let resizedHeight = Int(image.height) / renderSizeType.sizeDividend
        guard let context = CGContext(data: nil,
                                      width: resizedWidth,
                                      height: resizedHeight,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        else {
            throw PhotoExportError.contextCreation(contextSize: .init(width: CGFloat(resizedWidth),
                                                                      height: CGFloat(resizedHeight)))
        }

        context.draw(image,
                     in: CGRect(
                         origin: .zero,
                         size: CGSize(width: resizedWidth,
                                      height: resizedHeight)
                     ))

        guard let resizedImage = context.makeImage() else {
            throw PhotoExportError.contextResizedImageMaking
        }

        return resizedImage
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

                context.setAllowsAntialiasing(false)
                context.setShouldAntialias(false)
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
                                         mask: Set<Pixel>,
                                         renderSizeType: RenderSizeType) async throws -> CGImage
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

            if magicWandModel.magicWandType == .magicWand {
                context.draw(layerImage, in: CGRect(x: 0,
                                                    y: 0,
                                                    width: contextWidth,
                                                    height: contextHeight))
                context.setBlendMode(.destinationOut)
                context.setFillColor(UIColor.white.cgColor)
                for pixel in mask {
                    context.fill(CGRect(x: pixel.x * renderSizeType.sizeDividend,
                                        y: contextHeight - pixel.y * renderSizeType.sizeDividend - 1,
                                        width: renderSizeType.sizeDividend,
                                        height: renderSizeType.sizeDividend))
                }
            } else if magicWandModel.magicWandType == .bucketFill {
                let shapeStyle = magicWandModel.currentBucketFillShapeStyle.shapeStyle
                let shapeStyleCG = magicWandModel.currentBucketFillShapeStyle.shapeStyleCG

                if let color = shapeStyle as? Color {
                    context.setFillColor(color.cgColor)
                    context.draw(layerImage, in: CGRect(x: 0,
                                                        y: 0,
                                                        width: contextWidth,
                                                        height: contextHeight))
                    for pixel in mask {
                        context.fill(CGRect(x: pixel.x * renderSizeType.sizeDividend,
                                            y: contextHeight - pixel.y * renderSizeType.sizeDividend - 1,
                                            width: renderSizeType.sizeDividend,
                                            height: renderSizeType.sizeDividend))
                    }
                } else if let cgLinearGradient = shapeStyleCG as? CGLinearGradient,
                          let cgGradient = cgLinearGradient.cgGradient
                {
                    let startPoint = cgLinearGradient.startPoint
                    let endPoint = cgLinearGradient.endPoint

                    UIGraphicsBeginImageContext(CGSize(width: contextWidth, height: contextHeight))
                    let gradientContext = UIGraphicsGetCurrentContext()!

                    let startX = CGFloat(contextWidth) * cgLinearGradient.startPoint.x
                    let startY = CGFloat(contextHeight) * cgLinearGradient.startPoint.y
                    let endX = CGFloat(contextWidth) * cgLinearGradient.endPoint.x
                    let endY = CGFloat(contextHeight) * cgLinearGradient.endPoint.y

                    let start = CGPoint(x: startX, y: startY)
                    let end = CGPoint(x: endX, y: endY)

                    gradientContext.drawLinearGradient(cgGradient, start: start, end: end, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])

                    let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    UIGraphicsBeginImageContext(CGSize(width: contextWidth, height: contextHeight))
                    let imageContext = UIGraphicsGetCurrentContext()!

                    imageContext.translateBy(x: 0, y: CGFloat(contextHeight))
                    imageContext.scaleBy(x: 1.0, y: -1.0)

                    imageContext.draw(layerImage, in: CGRect(x: 0, y: 0, width: contextWidth, height: contextHeight))

                    imageContext.setBlendMode(.destinationOut)
                    imageContext.setFillColor(UIColor.white.cgColor)

                    for pixel in mask {
                        imageContext.fill(CGRect(x: pixel.x * renderSizeType.sizeDividend, y: contextHeight - pixel.y * renderSizeType.sizeDividend - 1, width: renderSizeType.sizeDividend, height: renderSizeType.sizeDividend))
                    }

                    let imageWithHoles = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    UIGraphicsBeginImageContext(CGSize(width: contextWidth, height: contextHeight))

                    context.draw(gradientImage!.cgImage!, in: CGRect(x: 0, y: 0, width: contextWidth, height: contextHeight))

                    context.draw(imageWithHoles!.cgImage!, in: CGRect(x: 0, y: 0, width: contextWidth, height: contextHeight))
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
                                magicWandModel: MagicWandModel,
                                renderSizeType: RenderSizeType = .quarter,
                                _ frameSize: CGSize,
                                _ marginedWorkspaceSize: CGSize) async throws -> CGImage
    {
        let tappedX = Int(min(layer.pixelSize.width - 1, max(0.0, round(tapPosition.x))))
        let tappedY = Int(min(layer.pixelSize.height - 1, max(0.0, round(tapPosition.y))))

        let width = layerImage.width / renderSizeType.sizeDividend
        let height = layerImage.height / renderSizeType.sizeDividend

        let absScaledX =
            CGFloat(tappedX / renderSizeType.sizeDividend)
                * layer.pixelSize.width / frameSize.width

        let absScaledY =
            CGFloat(tappedY / renderSizeType.sizeDividend)
                * layer.pixelSize.height / frameSize.height

        let scaledX = copysign(-1.0, layer.scaleX ?? 1.0) == 1.0
            ? absScaledX
            : CGFloat(width) - absScaledX

        let scaledY = copysign(-1.0, layer.scaleY ?? 1.0) == 1.0
            ? absScaledY
            : CGFloat(height) - absScaledY

        let tappedPixel = Pixel(x: min(Int(round(max(scaledX, 0))), width - 1),
                                y: min(Int(round(max(scaledY, 0))), height - 1))

        let resizedPhoto = try renderResizedPhoto(image: layerImage, renderSizeType: renderSizeType)

        let bytesPerRow = resizedPhoto.bytesPerRow

        guard let dataProvider = resizedPhoto.dataProvider,
              let data = dataProvider.data,
              let imageData = CFDataGetBytePtr(data)
        else {
            throw PhotoExportError.dataRetrieving
        }

        let pixelArray = imageData.toRGBABytesArray(width: width, height: height, bytesPerRow: bytesPerRow)

        let initialPixelColor: CGColor = getPixelColor(pixelArray[tappedPixel])

        guard let initialColorComponents = initialPixelColor.components else {
            throw PhotoExportError.dataRetrieving
        }

        let matchingPixelsSet = floodFillForMatchingPixels(
            initialPixel: tappedPixel,
            referenceColorComponents: initialColorComponents,
            tolerance: magicWandModel.tolerance,
            width, height, pixelArray
        )

        let smoothnessLevel = 2
        var mask = matchingPixelsSet

        for pixel in matchingPixelsSet {
            for x in -smoothnessLevel ... smoothnessLevel where x != 0 {
                for y in -smoothnessLevel ... smoothnessLevel where y != 0 {
                    mask.insert(Pixel(x: pixel.x + x, y: pixel.y + y))
                }
            }
        }

        let resultImage = try await renderImageAfterMagicWandAction(
            layer: layer,
            layerImage: layerImage,
            magicWandModel: magicWandModel,
            mask: mask,
            renderSizeType: renderSizeType
        )

        return resultImage
    }

    private func getPixelColor(_ pixelBytes: UInt32) -> CGColor {
        let red = CGFloat((pixelBytes >> 24) & 0xFF) / 255.0
        let green = CGFloat((pixelBytes >> 16) & 0xFF) / 255.0
        let blue = CGFloat((pixelBytes >> 8) & 0xFF) / 255.0
        let alpha = CGFloat(pixelBytes & 0xFF) / 255.0

        return CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    private func isColorSimilar(colorToCheck: CGColor, _ referenceColorComponents: [CGFloat], _ tolerance: CGFloat) -> Bool {
        guard let colorToCheckComponents = colorToCheck.components else { return false }

        for index in 0 ... 2 {
            if abs(colorToCheckComponents[index] - referenceColorComponents[index]) > tolerance {
                return false
            }
        }
        return true
    }

    private func floodFillForMatchingPixels(initialPixel: Pixel,
                                            referenceColorComponents: [CGFloat],
                                            tolerance: CGFloat,
                                            _ width: Int,
                                            _ height: Int,
                                            _ pixelArray: [[UInt32]])
        -> Set<Pixel>
    {
        var visitedPixelsArray: [[Bool]] = Array(repeating: Array(repeating: false, count: width), count: height)
        var matchingPixelsArray: Set<Pixel> = [initialPixel]

        var pixelToVisitStack: [Pixel] = [initialPixel]
        visitedPixelsArray[initialPixel.y][initialPixel.x] = true

        while !pixelToVisitStack.isEmpty {
            let currentPixel = pixelToVisitStack.removeLast()

            let currentPixelColor = getPixelColor(pixelArray[currentPixel])
            let isColorSimilar = isColorSimilar(colorToCheck: currentPixelColor, referenceColorComponents, tolerance)

            guard isColorSimilar else { continue }

            matchingPixelsArray.insert(Pixel(x: currentPixel.x, y: currentPixel.y))

            if currentPixel.x - 1 >= 0, !visitedPixelsArray[currentPixel.y][currentPixel.x - 1] {
                pixelToVisitStack.append(Pixel(x: currentPixel.x - 1, y: currentPixel.y))
                visitedPixelsArray[currentPixel.y][currentPixel.x - 1] = true
            }
            if currentPixel.x + 1 < width, !visitedPixelsArray[currentPixel.y][currentPixel.x + 1] {
                pixelToVisitStack.append(Pixel(x: currentPixel.x + 1, y: currentPixel.y))
                visitedPixelsArray[currentPixel.y][currentPixel.x + 1] = true
            }
            if currentPixel.y - 1 >= 0, !visitedPixelsArray[currentPixel.y - 1][currentPixel.x] {
                pixelToVisitStack.append(Pixel(x: currentPixel.x, y: currentPixel.y - 1))
                visitedPixelsArray[currentPixel.y - 1][currentPixel.x] = true
            }
            if currentPixel.y + 1 < height, !visitedPixelsArray[currentPixel.y + 1][currentPixel.x] {
                pixelToVisitStack.append(Pixel(x: currentPixel.x, y: currentPixel.y + 1))
                visitedPixelsArray[currentPixel.y + 1][currentPixel.x] = true
            }
        }
        return matchingPixelsArray
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
