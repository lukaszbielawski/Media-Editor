//
//  FilterCategoryType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/02/2024.
//

import Foundation

enum FilterCategoryType: Category {

    var id: String { shortName }

    case correction
    case effect
    case blur
    case distortion
    case special

    var shortName: String {
        return switch self {

        case .correction:
            "Correction"
        case .effect:
            "Effect"
        case .blur:
            "Blur"
        case .distortion:
            "Distortion"
        case .special:
            "Special"

        }
    }

    var thumbnailName: String {
        return switch self {
        case .correction:
            "saturation"
        case .effect:
            "sepia"
        case .blur:
            "motionBlur"
        case .distortion:
            "bump"
        case .special:
            "edgeWork"
        }
    }
}
