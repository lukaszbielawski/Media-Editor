//
//  FilterCategoryType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/02/2024.
//

import Foundation

enum FilterCategoryType: CaseIterable, Identifiable {

    var id: String { shortName }

    case blurs
    case colors

    var shortName: String {
        return switch self {
        case .blurs:
            "Blurs"
        case .colors:
            "Colors"
        }
    }

    var thumbnailName: String {
        return switch self {
        default:
            "FilterPreviewImageCaseNone"
        }
    }
}
