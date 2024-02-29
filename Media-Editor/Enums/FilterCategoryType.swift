//
//  FilterCategoryType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/02/2024.
//

import Foundation

enum FilterCategoryType: CaseIterable, Identifiable {

    var id: String { shortName }

    case blur
    case color

    var shortName: String {
        return switch self {
        case .blur:
            "Blur"
        case .color:
            "Invert"
        }
    }

    var thumbnailName: String {
        return switch self {
        default:
            "FilterPreviewImageCaseNone"
        }
    }
}
