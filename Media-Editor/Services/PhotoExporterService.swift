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

    func exportLayersToImage(photos: [LayerModel],
                             contextPixelSize: CGSize,
                             backgroundColor: CGColor) async throws -> CGImage
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
                        + position.x * photo.pixelToDigitalWidthRatio,
                    y:
                    contextPixelSize.height * 0.5
                        - centerTranslation.height * scaleY
                        - position.y * photo.pixelToDigitalHeightRatio
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

                context.concatenate(resultTransform)

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
