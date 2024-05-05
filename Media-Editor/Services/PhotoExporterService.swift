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
                          path: Path) async throws -> CGImage
    {
        return try await Task {
            guard let layerImage = layer.cgImage else { throw PhotoExportError.other }
            guard let context = CGContext(data: nil,
                                          width: Int(pixelCropSize.width),
                                          height: Int(pixelCropSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

            else { throw PhotoExportError.contextCreation(contextSize: .init(width: Int(pixelCropSize.width), height: Int(pixelCropSize.height))) }

            let bezierPath = UIBezierPath(cgPath: path.cgPath)

            let scaleTransform = CGAffineTransform(scaleX: 1,
                                                   y: -1)

            let correctionTranslation = CGAffineTransform(translationX: 0,
                                                          y: path.boundingRect.size.height)

            bezierPath.apply(scaleTransform.concatenating(correctionTranslation))

            context.addPath(bezierPath.cgPath)

            context.clip()

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

                if let layerBackgroundShapeStyle {
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

            guard let layerImage = layer.cgImage, let layerScaleX = layer.scaleX, let layerScaleY = layer.scaleY else { throw PhotoExportError.other }

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
                    print("hello")
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
