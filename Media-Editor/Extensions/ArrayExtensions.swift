//
//  ArrayExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/05/2024.
//

import Foundation

extension Array where Element == [UInt32] {
    subscript(pixel: Pixel) -> UInt32 {
        return self[pixel.y][pixel.x]
    }
}

extension Array where Element == [Bool] {
    subscript(pixel: Pixel) -> Bool {
        return self[pixel.y][pixel.x]
    }
}

