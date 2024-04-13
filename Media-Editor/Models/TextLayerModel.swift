//
//  TextLayerModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/04/2024.
//

import Foundation
import SwiftUI

final class TextLayerModel: LayerModel {
    @Published var textModelEntity: TextModelEntity {
        willSet {
            photoEntity.photoEntityToTextModelEntity = newValue
        }
    }

    @Published var text: String {
        willSet { textModelEntity.text = newValue }
    }

    @Published var fontName: String {
        willSet { textModelEntity.fontName = newValue }
    }

    @Published var fontSize: Int {
        willSet { textModelEntity.fontSize = newValue as NSNumber }
    }

    @Published var curveAngle: Angle {
        willSet { textModelEntity.curveDegrees = newValue.degrees as NSNumber }
    }

    @Published var textColor: Color {
        willSet {
            guard let hexString = newValue.hexString else { return }
            textModelEntity.textColorHex = hexString
        }
    }

    @Published var borderColor: Color {
        willSet {
            guard let hexString = newValue.hexString else { return }
            textModelEntity.borderColorHex = hexString
        }
    }

    @Published var borderSize: Int {
        willSet { textModelEntity.borderSize = newValue as NSNumber }
    }

    init(photoEntity: PhotoEntity, textModelEntity: TextModelEntity) {
        self.textModelEntity = textModelEntity
        self.text = textModelEntity.text
        self.fontName = textModelEntity.fontName
        self.fontSize = textModelEntity.fontSize.intValue
        self.curveAngle = Angle(degrees: textModelEntity.curveDegrees.doubleValue)
        self.textColor = Color(hex: textModelEntity.textColorHex)
        self.borderColor = Color(hex: textModelEntity.borderColorHex)
        self.borderSize = textModelEntity.borderSize.intValue

        super.init(photoEntity: photoEntity)
        self.photoEntity.photoEntityToTextModelEntity = textModelEntity
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        return TextLayerModel(photoEntity: photoEntity, textModelEntity: textModelEntity)
    }

    override func copy(withCGImage: Bool, with zone: NSZone? = nil) -> Any {
        let layerModel = copy(with: zone) as! TextLayerModel
        if withCGImage {
            layerModel.cgImage = cgImage
        }
        return layerModel
    }
}
