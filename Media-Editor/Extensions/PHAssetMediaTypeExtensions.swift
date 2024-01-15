//
//  PHAssetMediaTypeExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/01/2024.
//

import Foundation
import Photos

extension PHAssetMediaType {
    var toMediaType: ProjectType {
        switch self {
        case .image:
            return .photo
        case .video:
            return .movie
        default:
            return .unknown
        }
    }
}
