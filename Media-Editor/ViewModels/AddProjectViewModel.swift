//
//  AddProjectViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Foundation
import Photos

class AddProjectViewModel: ObservableObject {
    @Published var media: [PHAsset] = []

    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
            switch status {
            case .authorized:
                fetchMediaFromPhotoLibrary()
            default:
                print("Permission not granted")
            }
        }
    }

    private func fetchMediaFromPhotoLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1000
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        DispatchQueue.main.async { [self] in
            media += (0 ..< fetchResult.count).map { fetchResult.object(at: $0) }
        }
    }
}
