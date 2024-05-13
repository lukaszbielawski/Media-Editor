//
//  LayerToolType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation

enum LayerToolType: String, Tool {
    case filters
    case crop
    case draw
    case background
    case magicWand
    case flip
    case editText

    var id: String { return rawValue }
}

extension LayerToolType {
    var name: String {
        switch self {
        case .filters:
            return "Filters"
        case .crop:
            return "Crop"
        case .draw:
            return "Draw"
        case .background:
            return "Background"
        case .magicWand:
            return "Magic Wand"
        case .flip:
            return "Flip"
        case .editText:
            return "Edit text"
        }
    }

    var icon: String {
        switch self {
        case .filters:
            return "camera.filters"
        case .crop:
            return "crop"
        case .draw:
            return "pencil.and.scribble"
        case .background:
            return "rectangle.checkered"
        case .magicWand:
            return "wand.and.stars.inverse"
        case .flip:
            return "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"
        case .editText:
            return "character.cursor.ibeam"
        }
    }

    var isFocusViewTool: Bool {
        switch self {
        case .filters:
            false
        case .crop:
            true
        case .draw:
            true
        case .background:
            true
        case .magicWand:
            true
        case .flip:
            false
        case .editText:
            false
        }
    }
}
