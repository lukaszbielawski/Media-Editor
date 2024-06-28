//
//  MagicWandType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/05/2024.
//

import Foundation

enum MagicWandType: CaseIterable {
    case magicWand
    case bucketFill

    var name: String {
        switch self {
        case .magicWand:
            "Magic Wand"
        case .bucketFill:
            "Bucket Fill"
        }
    }

    var iconName: String {
        switch self {
        case .magicWand:
            "wand.and.stars.inverse"
        case .bucketFill:
            "bucket.fill"
        }
    }
}
