//
//  ProjectSingleActionToolType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/03/2024.
//

import Foundation

enum ProjectSingleActionToolType: String, Tool {
    case merge

    var id: String { return rawValue }
}

extension ProjectSingleActionToolType {
    var name: String {
        switch self {
        case .merge:
            return "Merge"
        }
    }

    var icon: String {
        switch self {
        case .merge:
            return "point.3.filled.connected.trianglepath.dotted"
        }
    }
}
