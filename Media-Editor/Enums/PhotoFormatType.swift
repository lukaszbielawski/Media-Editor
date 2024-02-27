//
//  PhotoFormatType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Foundation

enum PhotoFormatType: CaseIterable {
    case png
    case jpeg
}

extension PhotoFormatType {
    var toString: String {
        switch self {
        case .png:
            ".PNG"
        case .jpeg:
            ".JPEG"
        }
    }
}
