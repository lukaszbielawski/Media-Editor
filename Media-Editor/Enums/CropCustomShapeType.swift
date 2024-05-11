//
//  CropCustomShapeType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/05/2024.
//

import Foundation

enum CropCustomShapeType: CaseIterable {
    case drag
    case addDot
    case removeDot

    var title: String {
        switch self {
        case .drag:
            "Drag"
        case .addDot:
            "Add dot"
        case .removeDot:
            "Remove dot"
        }
    }

    var iconName: String {
        switch self {
        case .drag:
            "hand.draw.fill"
        case .addDot:
            "circle.badge.plus.fill"
        case .removeDot:
            "circle.badge.minus.fill"
        }
    }
}
