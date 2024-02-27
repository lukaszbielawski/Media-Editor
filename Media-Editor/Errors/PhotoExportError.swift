//
//  PhotoExportError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 27/02/2024.
//

import Foundation

enum PhotoExportError: Error {
    case contextCreation
    case contextImageMaking
    case colorSpace
    case contextResizedImageMaking
    case dataRetrieving
}
