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

    var category: FilterCategoryType {
        return switch self {
        case .gaussianBlur:
            .blur
        case .colorInvert:
            .color
        }
    }

    mutating func changeValue(value: CGFloat) {
        switch self {
        case .gaussianBlur:
            self = .gaussianBlur(radius: value)
        default:
            break
        }
    }

    var filterName: String {
        return switch self {
        case .gaussianBlur:
            "CIGaussianBlur"
        case .colorInvert:
            "CIColorInvert"
        }
    }

    var shortName: String {
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
            0.00 ... 50.0
        default:
            nil
        }
    }

    var parameterRangeAverage: CGFloat? {
        guard let parameterValueRange else { return nil }
        return (parameterValueRange.upperBound -
                parameterValueRange.lowerBound) * 0.5
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

    var thumbnailName: String {
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
            print(radius)
            filter?.setValue(radius, forKey: kCIInputRadiusKey)
        case .colorInvert:
            break
        }
        return filter!
    }
}
