//
//  ToolType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import Foundation

enum ToolType: String, CaseIterable, Identifiable {
    case none
    case add
    case layers
    case resize

    var id: String { return self.rawValue }
}

extension ToolType {
    var name: String {
        switch self {
        case .add:
            return "Add"
        case .layers:
            return "Layers"
        case .resize:
            return "Resize"
        default:
            return ""
        }
    }

    var icon: String {
        switch self {
        case .add:
            return "photo.badge.plus.fill"
        case .layers:
            return "square.3.layers.3d.top.filled"
        case .resize:
            return "square.resize.up"
        default:
            return ""
        }
    }
}
