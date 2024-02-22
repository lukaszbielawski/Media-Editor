//
//  CGImageError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 17/01/2024.
//

import Foundation

enum CGImageError: Error {
    case dataFromFile
    case sourceCreation
    case imageFromSourceCreation
    case contextCreation
}

extension CGImageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .dataFromFile:
            "Error while creating Data object from URL occured"
        case .sourceCreation:
            "Error while creating CGImageSource from Data occured"
        case .imageFromSourceCreation:
            "Error while creating CGImage from CGImageSource occured"
        case .contextCreation:
            "Error while creating CGContext"
        }
    }
}
