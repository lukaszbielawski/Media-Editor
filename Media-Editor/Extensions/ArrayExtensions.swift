//
//  ArrayExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/05/2024.
//

import Foundation

extension Array where Element == UInt8 {
    var toUInt32Array: [UInt32] {
        let numBytes = self.count
        var byteArrSlice = self[0..<numBytes]

        var arr = [UInt32](repeating: 0, count: numBytes/4)
        for i in (0..<numBytes/4).reversed() {
            arr[i] = UInt32(byteArrSlice.removeLast()) + UInt32(byteArrSlice.removeLast()) << 8 + UInt32(byteArrSlice.removeLast()) << 16 + UInt32(byteArrSlice.removeLast()) << 24
        }
        return arr
    }
}

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

