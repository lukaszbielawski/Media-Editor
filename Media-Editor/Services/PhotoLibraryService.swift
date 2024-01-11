//
//  PhotoLibraryService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Foundation
import Photos
import UIKit

class PhotoLibraryService: ObservableObject {
    @Published var media: PHFetchResult<PHAsset> = .init()
    
    var imageCachingManager = PHCachingImageManager()
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
            switch status {
            case .authorized, .limited:
                fetchAllMediaFromPhotoLibrary()
            default:
                print("Permission not granted")
            }
        }
    }
    
    func getMediaPublisher() -> Published<PHFetchResult<PHAsset>>.Publisher {
        return _media.projectedValue
    }

    func fetchAllMediaFromPhotoLibrary() {
        imageCachingManager.allowsCachingHighQualityImages = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        DispatchQueue.main.async { [unowned self] in
            media = PHAsset.fetchAssets(with: fetchOptions)
        }
    }
    
    func fetchAsset(for localIdentifier: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
    }
    
    func fetchThumbnail(for localIdentifier: String, desiredSize: CGSize, contentMode: PHImageContentMode = .default) async throws -> UIImage {
        let asset: PHAsset? = fetchAsset(for: localIdentifier)
        
        guard let asset else { throw PhotoError.invalidLocalIdentifier(localIdentifier: localIdentifier) }
        
        guard asset.mediaType == .video || asset.mediaType == .image else { throw PhotoError.invalidMediaType }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .opportunistic
        
        let photo = try await withCheckedThrowingContinuation { continuation in
            imageCachingManager.requestImage(for: asset, targetSize: desiredSize, contentMode: contentMode, options: requestOptions) { image, _ in
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
        
        guard let resource = resources.first else { throw PhotoError.noAssetResources(localIdentifier: localIdentifier)  }
        
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
        print(fileExtension)
        fileURL = fileURL.appendingPathExtension(fileExtension)

        print(fileURL)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            throw FileError.store(url: fileURL)
        }
    }
}
