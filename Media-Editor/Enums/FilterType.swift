//
//  FilterType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation
import UIKit

enum FilterType: CaseIterable, Equatable {
    case boxBlur(radius: CGFloat)
    case gaussianBlur(radius: CGFloat)
    case colorInvert

    var category: FilterCategoryType {
        return switch self {
        case .boxBlur,
             .gaussianBlur:
            .blurs
        case .colorInvert:
            .colors
        }
    }

    var filterName: String {
        return switch self {
        case .boxBlur:
            "CIBoxBlur"
        case .gaussianBlur:
            "CIGaussianBlur"
        case .colorInvert:
            "CIColorInvert"
        }
    }

    var shortName: String {
        return switch self {
        case .boxBlur:
            "Box"
        case .gaussianBlur:
            "Gauss"
        case .colorInvert:
            "Invert"
        }
    }

    var parameterValueRange: ClosedRange<CGFloat>? {
        return switch self {
        case .boxBlur:
            0.00 ... 200.0
        case .gaussianBlur:
            0.00 ... 200.0
        default:
            nil
        }
    }

    var parameterName: String? {
        return switch self {
        case .boxBlur, .gaussianBlur:
            "inputRadius"
        default:
            nil
        }
    }

    var parameterDefaultValue: CGFloat? {
        return switch self {
        case .boxBlur:
            20.0
        case .gaussianBlur:
            20.0
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

    static var allCases: [Self] {
        return [.boxBlur(radius: boxBlur(radius: 0.0).parameterDefaultValue!),
                .gaussianBlur(radius: gaussianBlur(radius: 0.0).parameterDefaultValue!),
                .colorInvert]
    }

    mutating func changeValue(value: CGFloat) {
        switch self {
        case .boxBlur:
            self = .gaussianBlur(radius: value)
        case .gaussianBlur:
            self = .gaussianBlur(radius: value)
        default:
            break
        }
    }

    func createFilter(image: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)
        filter?.setValue(image, forKey: kCIInputImageKey)

        let extendFactor = hypot(image.extent.size.width, image.extent.size.height) / referenceDiagonalWidth

        switch self {
        case .boxBlur(let radius):
            filter?.setValue(radius * extendFactor, forKey: kCIInputRadiusKey)
        case .gaussianBlur(let radius):
            filter?.setValue(radius * extendFactor, forKey: kCIInputRadiusKey)
        case .colorInvert:
            break
        }
        return filter!
    }
}

extension FilterType: Identifiable {
    var id: String { filterName }

    var parameterRangeAverage: CGFloat? {
        guard let parameterValueRange else { return nil }
        return (parameterValueRange.upperBound -
            parameterValueRange.lowerBound) * 0.5
    }

    var referenceDiagonalWidth: CGFloat {
        return hypot(3000, 2000)
    }
}
