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
    case background
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
        case .background:
            return "Background"
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
        case .background:
            return "rectangle.checkered"
        case .flip:
            return "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"
        case .editText:
            return "character.cursor.ibeam"
        }
    }
}
