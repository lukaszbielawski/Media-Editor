//
//  CropRatioType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import Foundation

enum CropRatioType: CaseIterable {
    case twoToOne
    case sixteenToNine
    case fourToThree
    case fiveToFour
    case oneToOne
    case fourToFive
    case threeToFour
    case nineToSixteen
    case oneToTwo
    case any

    var value: Double? {
        return switch self {
        case .twoToOne:
            2.0
        case .sixteenToNine:
            16.0/9.0
        case .fourToThree:
            4.0/3.0
        case .fiveToFour:
            5.0/4.0
        case .oneToOne:
            1.0
        case .fourToFive:
            4.0/5.0
        case .threeToFour:
            3.0/4.0
        case .nineToSixteen:
            9.0/16.0
        case .oneToTwo:
            1.0/2.0
        case .any:
            nil
        }
    }

    var text: String {
        return switch self {
        case .twoToOne:
            "2:1"
        case .sixteenToNine:
            "16:9"
        case .fourToThree:
            "4:3"
        case .fiveToFour:
            "5:4"
        case .oneToOne:
            "1:1"
        case .fourToFive:
            "4:5"
        case .threeToFour:
            "3:4"
        case .nineToSixteen:
            "9:16"
        case .oneToTwo:
            "1:2"
        case .any:
            "any"
        }
    }

    static var allCases: [CropRatioType] {
        [
            .oneToOne,
            .fiveToFour,
            .fourToThree,
            .sixteenToNine,
            .twoToOne,
            .any,
            .oneToTwo,
            .nineToSixteen,
            .threeToFour,
            .fourToFive,
            .oneToOne
        ]
    }
}
