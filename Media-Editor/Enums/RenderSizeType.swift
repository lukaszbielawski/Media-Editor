//
//  PhotoSizeType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 27/02/2024.
//

import Foundation

enum RenderSizeType {
    case preview
    case raw
    case threeQuarters
    case halfSize
    case quarter
    case ten
}

extension RenderSizeType: CaseIterable {
    static var allCases: [RenderSizeType] {
        return [.raw, .threeQuarters, .halfSize, .quarter, .ten]
    }

    var sizeFactor: CGFloat {
        switch self {
        case .preview:
            0.0
        case .raw:
            1.0
        case .threeQuarters:
            0.75
        case .halfSize:
            0.5
        case .quarter:
            0.25
        case .ten:
            0.1
        }
    }

    var toString: String {
        switch self {
        case .preview:
            ""
        case .raw:
            "Full"
        case .threeQuarters:
            "75%"
        case .halfSize:
            "50%"
        case .quarter:
            "25%"
        case .ten:
            "10%"
        }
    }
}
