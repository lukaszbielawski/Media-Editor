//
//  PhotoError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Foundation

enum PhotoError: Error, LocalizedError {
    case invalidLocalIdentifier(localIdentifier: String)
    case noAssetResources(localIdentifier: String)
    case thumbnailError
    case invalidMediaType
    case other
    
    var errorDescription: String? {
        switch self {
        case .invalidLocalIdentifier(let localIdentifier):
            return "Asset with identifier: \(localIdentifier) was not found"
        case .noAssetResources(let localIdentifier):
            return "There were no fetched resources from asset with identifier: \(localIdentifier)"
        case .thumbnailError:
            return "Thumbnail generation went wrong"
        case .invalidMediaType:
            return "Not supported media type"
        case .other:
            return "Unknown reason"
        }
    }
}
