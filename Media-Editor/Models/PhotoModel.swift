//
//  PhotoModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 17/01/2024.
//

import CoreGraphics
import Foundation
import ImageIO

struct PhotoModel: Identifiable {
    var id: String
    private var fileName: String
    var photoEntity: PhotoEntity

    var cgImage: CGImage!
    var positionX: Double
    var positionY: Double
    var positionZ: Int?
    var scaleX: Double
    var scaleY: Double

    init(photoEntity: PhotoEntity) {
        self.photoEntity = photoEntity
        self.fileName = photoEntity.fileName!
        self.id = fileName

        self.positionX = photoEntity.positionX!.doubleValue
        self.positionY = photoEntity.positionY!.doubleValue
        self.positionZ = photoEntity.positionZ?.intValue
        self.scaleX = photoEntity.scaleX!.doubleValue
        self.scaleY = photoEntity.scaleY!.doubleValue
        self.cgImage = try! createCGImage(absoluteFilePath: absoluteFilePath)
    }

    var absoluteFilePath: String {
        let mediaDirectoryPath: URL =
            FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("UserMedia")
        return mediaDirectoryPath
            .appendingPathComponent(fileName)
            .absoluteString.replacingOccurrences(of: "file://", with: "")
    }

    private func createCGImage(absoluteFilePath: String) throws -> CGImage? {
        let imageURL = URL(fileURLWithPath: absoluteFilePath)

        guard let imageData = try? Data(contentsOf: imageURL) else {
            throw CGImageError.dataFromFile
        }

        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            throw CGImageError.sourceCreation
        }

        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw CGImageError.imageFromSourceCreation
        }

        return cgImage
    }
}
