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

    var pixelSize: CGSize {
        return CGSize(width: cgImage.width, height: cgImage.height)
    }

    var pixelToDigitalWidthRatio: CGFloat {
        guard let size else { return .zero }
        return pixelSize.width / size.width
    }

    var pixelToDigitalHeightRatio: CGFloat {
        guard let size else { return .zero }
        return pixelSize.height / size.height
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

    func topLeftApexPosition(position newPosition: CGPoint? = nil) -> CGPoint {
        let position = newPosition ?? self.position
        guard let position, let size, let rotation, let scaleX, let scaleY else { return .zero }

        let apexX = position.x + size.height * 0.5 * sin(rotation.radians) * abs(scaleY)
            - size.width * 0.5 * cos(rotation.radians) * abs(scaleX)
        let apexY = position.y - size.height * 0.5 * cos(rotation.radians) * abs(scaleY)
            - size.width * 0.5 * sin(rotation.radians) * abs(scaleX)
        return CGPoint(x: apexX, y: apexY)
    }

    func topRightApexPosition(position newPosition: CGPoint? = nil) -> CGPoint {
        let position = newPosition ?? self.position
        guard let position, let size, let rotation, let scaleX, let scaleY else { return .zero }

        let apexX = position.x + size.height * 0.5 * sin(rotation.radians) * abs(scaleY)
            + size.width * 0.5 * cos(rotation.radians) * abs(scaleX)
        let apexY = position.y - size.height * 0.5 * cos(rotation.radians) * abs(scaleY)
            + size.width * 0.5 * sin(rotation.radians) * abs(scaleX)
        return CGPoint(x: apexX, y: apexY)
    }

    func bottomLeftApexPosition(position newPosition: CGPoint? = nil) -> CGPoint {
        let position = newPosition ?? self.position
        guard let position, let size, let rotation, let scaleX, let scaleY else { return .zero }

        let apexX = position.x - size.height * 0.5 * sin(rotation.radians) * abs(scaleY)
            - size.width * 0.5 * cos(rotation.radians) * abs(scaleX)
        let apexY = position.y + size.height * 0.5 * cos(rotation.radians) * abs(scaleY)
            - size.width * 0.5 * sin(rotation.radians) * abs(scaleX)
        return CGPoint(x: apexX, y: apexY)
    }

    func bottomRightApexPosition(position newPosition: CGPoint? = nil) -> CGPoint {
        let position = newPosition ?? self.position
        guard let position, let size, let rotation, let scaleX, let scaleY else { return .zero }

        let apexX = position.x - size.height * 0.5 * sin(rotation.radians) * abs(scaleY)
            + size.width * 0.5 * cos(rotation.radians) * abs(scaleX)
        let apexY = position.y + size.height * 0.5 * cos(rotation.radians) * abs(scaleY)
            + size.width * 0.5 * sin(rotation.radians) * abs(scaleX)
        return CGPoint(x: apexX, y: apexY)
    }

    func rotatedApexPositionFunction(apex: ApexType) -> ((CGPoint?) -> CGPoint) {
        guard let rotation else { return { _ in .zero } }
        let finalApex: ApexType
        if (0.0...45.0).contains(rotation.normalizedRotationDegrees)
            || (315.0...360.0).contains(rotation.normalizedRotationDegrees)
        {
            finalApex = apex
        } else if (225.0...315.0).contains(rotation.normalizedRotationDegrees) {
            finalApex = apex.nextType
        } else if (135.0...225.0).contains(rotation.normalizedRotationDegrees) {
            finalApex = apex.nextType.nextType
        } else {
            finalApex = apex.nextType.nextType.nextType
        }
        switch finalApex {
        case .topLeft:
            return topLeftApexPosition
        case .topRight:
            return topRightApexPosition
        case .bottomRight:
            return bottomRightApexPosition
        case .bottomLeft:
            return bottomLeftApexPosition
        }
    }
}

extension LayerModel: Equatable {
    static func == (lhs: LayerModel, rhs: LayerModel) -> Bool {
        return rhs.id == lhs.id
    }
}
