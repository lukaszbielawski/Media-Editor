//
//  LayerToolType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation

enum LayerToolType: String, Tool {
    case filters
    case flip

    var id: String { return rawValue }
}

extension LayerToolType {
    var name: String {
        switch self {
        case .filters:
            return "Filters"
        case .flip:
            return "Flip"
        }
    }

    var icon: String {
        switch self {
        case .filters:
            return "camera.filters"
        case .flip:
            return "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"
        }
    }
}
