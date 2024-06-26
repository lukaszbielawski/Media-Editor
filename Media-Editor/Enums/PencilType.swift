//
//  PencilType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import Foundation
import SwiftUI

enum PencilType: CaseIterable {
    case eraser
    case pencil
    case pen

    var name: String {
        switch self {
        case .eraser:
            "Eraser"
        case .pen:
            "Pen"
        case .pencil:
            "Pencil"
        }
    }

    var icon: String {
        switch self {
        case .eraser:
            "eraser.line.dashed.fill"
        case .pen:
            "pencil.tip"
        case .pencil:
            "pencil"
        }
    }
}
