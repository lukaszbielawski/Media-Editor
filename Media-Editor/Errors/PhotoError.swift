//
//  PhotoError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Foundation

enum PhotoError: Error, LocalizedError {
    case invalidLocalIdentifier(localIdentifier: String)
    case thumbnailError
    case other
    
    var errorDescription: String? {
        switch self {
        case .invalidLocalIdentifier(let localIdentifier):
            return "Asset with identifier: \(localIdentifier) was not found"
        case .thumbnailError:
            return "Thumbnail generation went wrong"
        case .other:
            return "Unknown reason"
        }
    }
}
