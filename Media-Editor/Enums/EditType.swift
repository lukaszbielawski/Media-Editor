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
    case leadingResize(translation: CGSize)
    case topResize(translation: CGSize)
    case trailingResize(translation: CGSize)
    case bottomResize(translation: CGSize)
    case save
}
