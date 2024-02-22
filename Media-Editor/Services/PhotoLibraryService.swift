//
//  PhotoLibraryService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Combine
import CoreGraphics
import Foundation
import Photos
import UIKit

class PhotoLibraryService: ObservableObject {
    var mediaPublisher = PassthroughSubject<[PHAsset], Never>()

    private var imageCachingManager: PHCachingImageManager!

    func requestAuthorization(projectType: Set<ProjectType>) {
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
            switch status {
            case .authorized, .limited:
                fetchAllMediaFromPhotoLibrary(projectType: projectType)
            default:
                print("Permission not granted")
            }
        }
    }

    func fetchAllMediaFromPhotoLibrary(projectType: Set<ProjectType>) {
        imageCachingManager = PHCachingImageManager()
        imageCachingManager.allowsCachingHighQualityImages = true

        let cvargs: [CVarArg] = projectType
            .map { type in
                if type == .movie {
                    return PHAssetMediaType.video.rawValue
                } else {
                    return PHAssetMediaType.image.rawValue
                }
            }

        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d || mediaType == %d",
            cvargs
        )

        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        mediaPublisher.send(
            {
                let fetchRequest = PHAsset.fetchAssets(with: fetchOptions)
                var assets = [PHAsset]()

                fetchRequest.enumerateObjects { asset, _, _ in
                    assets.append(asset)
                }
                return assets
            }()
        )
    }

    func fetchAsset(for localIdentifier: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
    }

    func fetchThumbnail(for localIdentifier: String,
                        desiredSize: CGSize,
                        contentMode: PHImageContentMode = .default) async throws -> UIImage
    {
        let asset: PHAsset? = fetchAsset(for: localIdentifier)

        guard let asset else { throw PhotoError.invalidLocalIdentifier(localIdentifier: localIdentifier) }

        guard asset.mediaType == .video || asset.mediaType == .image else { throw PhotoError.invalidMediaType }

        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .opportunistic

        let photo
            = try await withCheckedThrowingContinuation { continuation in
                imageCachingManager.requestImage(for: asset,
                                                 targetSize: desiredSize,
                                                 contentMode: contentMode,
                                                 options: requestOptions)
                { image, _ in
                    if let image {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(throwing: PhotoError.thumbnailError)
                    }
                }
            }
        return photo
    }

    func fetchMediaDataAndExtensionFromPhotoLibrary(with localIdentifier: String) async throws -> (Data, String) {
        let asset = fetchAsset(for: localIdentifier)
        guard let asset else {
            throw PhotoError.invalidLocalIdentifier(localIdentifier: localIdentifier)
        }

        let resources = PHAssetResource.assetResources(for: asset)

        guard let resource = resources.first else {
            throw PhotoError.noAssetResources(localIdentifier: localIdentifier)
        }

        let fileExtension = URL(fileURLWithPath: resource.originalFilename).pathExtension

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        let data = try await withCheckedThrowingContinuation { continuation in
            imageCachingManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                if let data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: PhotoError.other)
                }
            }
        }
        return (data, fileExtension)
    }

    func saveToDisk(data: Data, extension fileExtension: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let fileURL = try saveFileLocally(data: data, extension: fileExtension)
                continuation.resume(returning: fileURL)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func saveFileLocally(data: Data, extension fileExtension: String) throws -> URL {
        let fileManager = FileManager.default

        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileError.documentDirectory
        }

        var fileURL = documentsDirectory
        let folderName = "UserMedia"

        fileURL.appendPathComponent(folderName)
        do {
            try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw FileError.subdirectory
        }

        fileURL.appendPathComponent(UUID().uuidString)
        fileURL = fileURL.appendingPathExtension(fileExtension)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            throw FileError.store(url: fileURL)
        }
    }

    func saveAssetsAndGetFileNames(assets: [PHAsset]) async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self, returning: [String].self) { [unowned self] group in
            var array = [String]()
            for asset in assets {
                group.addTask { [unowned self] in
                    let (assetData, fileExtension)
                        = try await fetchMediaDataAndExtensionFromPhotoLibrary(with: asset.localIdentifier)
                    let savedFileURL = try await saveToDisk(data: assetData, extension: fileExtension)
                    return savedFileURL.lastPathComponent
                }
            }
            for try await fileName in group {
                array.append(fileName)
            }
            return array
        }
    }

    func exportPhotosToFile(photos: [LayerModel], contextPixelSize: CGSize) async {
        Task {
            guard let context = CGContext(data: nil,
                                          width: Int(contextPixelSize.width),
                                          height: Int(contextPixelSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return }

            context.setFillColor(UIColor.systemMint.cgColor)
            context.fill(CGRect(origin: .zero, size: contextPixelSize))

            for photo in photos where photo.positionZ != nil && photo.positionZ! > 0 {
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

            guard let resultImage = context.makeImage() else { return }

            let resultUIImage = UIImage(cgImage: resultImage)

            UIImageWriteToSavedPhotosAlbum(resultUIImage, nil, nil, nil)
            print("success")
        }
    }
}
