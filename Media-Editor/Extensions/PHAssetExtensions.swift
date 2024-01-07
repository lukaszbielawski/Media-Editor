//
//  PHAssetExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Foundation
import Photos
import UIKit
import AVKit

 extension PHAsset {
    func getThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        if self.mediaType == .video {
            imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                completion(image)
            }
        } else if self.mediaType == .image {
//            PHImageManagerMaximumSize
            imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .default, options: requestOptions) { image, _ in
                completion(image)
            }
        } else {
            completion(nil)
        }
    }
 }
