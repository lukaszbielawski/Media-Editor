//
//  ApexType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 14/02/2024.
//

import Foundation

enum ApexType {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft

    var nextType: Self {
        switch self {
        case .topLeft:
            return .topRight
        case .topRight:
            return .bottomRight
        case .bottomRight:
            return .bottomLeft
        case .bottomLeft:
            return .topLeft
        }
    }
}
