//
//  LayerSingleActionToolType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/03/2024.
//

import Foundation

enum LayerSingleActionToolType: String, Tool {
    case copy

    var id: String { return rawValue }
}

extension LayerSingleActionToolType {
    var name: String {
        switch self {
        case .copy:
            return "Copy"
        }
    }

    var icon: String {
        switch self {
        case .copy:
            return "photo.fill.on.rectangle.fill"
        }
    }
}
