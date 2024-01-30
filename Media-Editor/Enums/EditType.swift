//
//  EditType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation
import SwiftUI

enum EditType {
    case delete
    case rotation(angle: Angle)
    case rotateLeft
    case flip
    case aspectResize(translation: CGSize)
    case leadingResize(widthDiff: CGFloat)
    case topResize(heightDiff: CGFloat)
    case trailingResize(widthDiff: CGFloat)
    case bottomResize(heightDiff: CGFloat)
    case save
}
