//
//  FilterType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation
import UIKit

enum FilterType: Identifiable, CaseIterable, Equatable {
    static var allCases: [Self] {
        return [.gaussianBlur(radius: 10.0), .colorInvert]
       }

    case gaussianBlur(radius: CGFloat)
    case colorInvert

    var id: String { self.filterName }

    var filterName: String {
        return switch self {
        case .gaussianBlur:
            "CIGaussianBlur"
        case .colorInvert:
            "CIColorInvert"
        }
    }

    var filterShortName: String {
        return switch self {
        case .gaussianBlur:
            "Blur"
        case .colorInvert:
            "Invert"
        }
    }

    var parameterValueRange: ClosedRange<CGFloat>? {
        return switch self {
        case .gaussianBlur:
            0.00...50.0
        default:
           nil
        }
    }

    var parameterName: String? {
        return switch self {
        case .gaussianBlur:
            "inputRadius"
        default:
            nil
        }
    }

    var parameterDefaultValue: CGFloat? {
        return switch self {
        case .gaussianBlur:
            10.0
        default:
            nil
        }
    }

    var photoName: String {
        return switch self {
        default:
            "FilterPreviewImageCaseNone"
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
