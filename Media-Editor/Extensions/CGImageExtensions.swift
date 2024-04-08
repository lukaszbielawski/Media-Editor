//
//  CGImageExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/04/2024.
//

import Foundation
import UIKit

extension CGImage {
    func cropImageByAlpha() -> CGImage {
        let context = self.createARGBBitmapContextFromImage()
        let height = self.height
        let width = self.width

        var rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        context?.draw(self, in: rect)

        let pixelData = self.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var minX = width
        var minY = height
        var maxX = 0
        var maxY = 0

        var left = 0
        var right = width - 1
        while left <= right {
            let mid = (left + right) / 2
            var found = false

            for y in 0..<height {
                let pixelIndex = (width * y + mid) * 4
                if data[Int(pixelIndex)] != 0 {
                    found = true
                    break
                }
            }

            if found {
                minX = min(minX, mid)
                right = mid - 1
            } else {
                left = mid + 1
            }
        }

        left = 0
        right = width - 1
        while left <= right {
            let mid = (left + right) / 2
            var found = false

            for y in 0..<height {
                let pixelIndex = (width * y + mid) * 4
                if data[Int(pixelIndex)] != 0 {
                    found = true
                    break
                }
            }

            if found {
                maxX = max(maxX, mid)
                left = mid + 1
            } else {
                right = mid - 1
            }
        }

        left = 0
        right = height - 1
        while left <= right {
            let mid = (left + right) / 2
            var found = false

            for x in 0..<width {
                let pixelIndex = (width * mid + x) * 4
                if data[Int(pixelIndex)] != 0 {
                    found = true
                    break
                }
            }

            if found {
                minY = min(minY, mid)
                right = mid - 1
            } else {
                left = mid + 1
            }
        }

        left = 0
        right = height - 1
        while left <= right {
            let mid = (left + right) / 2
            var found = false

            for x in 0..<width {
                let pixelIndex = (width * mid + x) * 4
                if data[Int(pixelIndex)] != 0 {
                    found = true
                    break
                }
            }

            if found {
                maxY = max(maxY, mid)
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        if let context {
            free(context.data)
        }
        rect = CGRect(x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(maxX - minX), height: CGFloat(maxY - minY))
        let cgImage = self.cropping(to: rect)

        return cgImage!
    }

    private func createARGBBitmapContextFromImage() -> CGContext? {
        let width = self.width
        let height = self.height

        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }

        let context = CGContext(data: bitmapData,
                                width: width, height:
                                height, bitsPerComponent: 8,
                                bytesPerRow: bitmapBytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

        return context
    }
}
