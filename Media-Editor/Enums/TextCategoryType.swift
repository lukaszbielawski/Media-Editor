//
//  TextCategoryType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/04/2024.
//

import Foundation

enum TextCategoryType: Category {

    var id: String { shortName }

    case textColor
    case fontName
    case fontSize
    case curve
    case border

    var shortName: String {
        return switch self {

        case .textColor:
            "Text Color"
        case .fontName:
            "Font Name"
        case .fontSize:
            "Font Size"
        case .curve:
            "Curve"
        case .border:
            "Border"
        }
    }

    var thumbnailName: String {
        switch self {
        case .textColor:
            return "paintpalette.fill"
        case .fontName:
            return "textformat.abc"
        case .fontSize:
            return "textformat.size"
        case .curve:
            return "road.lanes.curved.right"
        case .border:
            return "character.textbox"
        }
    }
}
