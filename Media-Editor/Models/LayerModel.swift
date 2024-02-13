//
//  PhotoModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 17/01/2024.
//

import CoreGraphics
import Foundation
import ImageIO
import SwiftUI

class LayerModel: Identifiable, ObservableObject {
    var id: String { fileName }
    var fileName: String
    var cgImage: CGImage!

    let photoEntity: PhotoEntity
    
    @Published var position: CGPoint? {
        willSet {
            photoEntity.positionX = newValue!.x as NSNumber
            photoEntity.positionY = newValue!.y as NSNumber
        }
    }

    @Published var positionZ: Int? {
        willSet { photoEntity.positionZ = newValue as? NSNumber }
    }

    @Published var rotation: Angle? {
        willSet { photoEntity.rotation = newValue!.radians as NSNumber }
    }

    @Published var scaleX: Double? {
        willSet { photoEntity.scaleX = newValue! as NSNumber }
    }

    @Published var scaleY: Double? {
        willSet { photoEntity.scaleY = newValue! as NSNumber }
    }

    @Published var size: CGSize?

    init(photoEntity: PhotoEntity) {
        self.photoEntity = photoEntity
        self.fileName = photoEntity.fileName!

        self.positionZ = photoEntity.positionZ?.intValue
        self.cgImage = try! createCGImage(absoluteFilePath: absoluteFilePath)

        self.position = CGPoint(x: photoEntity.positionX!.doubleValue, y: photoEntity.positionY!.doubleValue as Double)
        self.rotation = Angle(radians: photoEntity.rotation as? Double ?? .zero)

        self.scaleX = photoEntity.scaleX as? Double ?? 1.0
        self.scaleY = photoEntity.scaleY as? Double ?? 1.0
    }
}

extension LayerModel {
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

extension LayerModel: Equatable {
    static func == (lhs: LayerModel, rhs: LayerModel) -> Bool {
        return rhs.id == lhs.id
    }
}
