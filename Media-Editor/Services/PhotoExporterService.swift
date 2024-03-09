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
            guard let context = CGContext(data: nil,
                                          width: Int(pixelCropSize.width),
                                          height: Int(pixelCropSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

            else { throw PhotoExportError.contextCreation }

            let scaleXSign = copysign(-1.0, layer.scaleX ?? 1.0)
            let scaleYSign = copysign(-1.0, layer.scaleY ?? 1.0)

            let bezierPath = UIBezierPath(cgPath: path.cgPath)

            let scaleTransform = CGAffineTransform(scaleX: 1,
                                                   y: -1)

            let correctionTranslation = CGAffineTransform(translationX: 0,
                                                          y: path.boundingRect.size.height)

            bezierPath.apply(scaleTransform.concatenating(correctionTranslation))

            context.addPath(bezierPath.cgPath)
            context.clip()

            context.translateBy(
                x: (pixelCropSize.width - pixelFrameSize.width) * 0.5 * scaleXSign,
                y: (pixelCropSize.height - pixelFrameSize.height) * 0.5 * scaleYSign
            )
            context.translateBy(x: -pixelOffset.width * scaleXSign, y: pixelOffset.height * scaleYSign)

            context.draw(layer.cgImage, in: CGRect(x: 0,
                                                   y: 0,
                                                   width: CGFloat(layer.cgImage.width),
                                                   height: CGFloat(layer.cgImage.height)))

            let clippedImage = context.makeImage()

            guard let clippedImage else { throw PhotoExportError.contextImageMaking }

            return clippedImage

        }.value
    }

    func exportLayersToImage(photos: [LayerModel],
                             contextPixelSize: CGSize,
                             backgroundColor: CGColor,
                             offsetFromCenter: CGPoint = .zero,
                             layersBackgroundColor: CGColor? = nil,
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
            else { throw PhotoExportError.contextCreation }

            context.setFillColor(backgroundColor)
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

                if let layersBackgroundColor {
                    context.setFillColor(layersBackgroundColor)
                    context.fill(CGRect(origin: .zero, size: .init(width: photo.pixelSize.width,
                                                                   height: photo.pixelSize.height)))
                }

                context.draw(photo.cgImage, in:
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
}
