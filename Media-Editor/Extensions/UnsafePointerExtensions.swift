//
//  UnsafePointerExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/05/2024.
//

import Foundation

extension UnsafePointer where Pointee == UInt8 {
    func toRGBABytesArray(width: Int, height: Int, bytesPerRow: Int) -> [[UInt32]] {
        var currentPointer = self
        var returnArray = [[UInt32]]()

        for _ in 1 ... height {
            let uint32Buffer: UnsafeBufferPointer<UInt32> =
                UnsafeBufferPointer(start: currentPointer, count: width * 4).withMemoryRebound(to: UInt32.self) { buffer in
                    buffer.withMemoryRebound(to: UInt32.self) { buffer in 
                        UnsafeBufferPointer(start: buffer.baseAddress!, count: width)
                    }
                }
            returnArray.append(Array(uint32Buffer))
            let nextPointer = currentPointer.advanced(by: bytesPerRow)
            currentPointer = nextPointer

        }

        return returnArray
    }
}

