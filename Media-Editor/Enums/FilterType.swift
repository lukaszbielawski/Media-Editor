//
//  FilterType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation
import UIKit

enum FilterType {
    case gaussianBlur(radius: CGFloat)
    case colorInvert

    var filterName: String {
        return switch self {
        case .gaussianBlur:
            "CIGaussianBlur"
        case .colorInvert:
            "CIColorInvert"
        }
    }
}

extension FilterType {
    func createFilter(image: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)
        filter?.setValue(image, forKey: kCIInputImageKey)
        switch self {
        case .gaussianBlur(let radius):
            filter?.setValue(radius, forKey: kCIInputRadiusKey)
        case .colorInvert:
            break
        }
        return filter!
    }
}
