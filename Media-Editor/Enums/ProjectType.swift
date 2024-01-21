//
//  ProjectType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Foundation

enum ProjectType {
    case photo
    case movie
    case unknown
}

extension ProjectType {
    var projectColor: ColorResource {
        switch self {
        case .photo:
            return .accent
        default:
            return .accent2
        }
    }
}
