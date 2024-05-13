//
//  ColorPickerType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/04/2024.
//

import Foundation

enum ColorPickerType {
    case projectBackground
    case layerBackground
    case textColor
    case borderColor
    case pencilColor
    case bucketColorPicker

    var pickerType: TextureType {
        switch self {
        case .projectBackground:
            .colorOpacity
        case .layerBackground:
            .gradient
        case .textColor:
            .colorOpacity
        case .borderColor:
            .colorOpacity
        case .pencilColor:
            .gradient
        case .bucketColorPicker:
            .gradient
        }
    }
}
