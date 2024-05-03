//
//  TextModelEntity.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/04/2024.
//
//

import CoreData
import Foundation

public class TextModelEntity: NSManagedObject {}

public extension TextModelEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TextModelEntity> {
        return NSFetchRequest<TextModelEntity>(entityName: "TextModelEntity")
    }

    @NSManaged var id: UUID
    @NSManaged var text: String
    @NSManaged var fontName: String
    @NSManaged var fontSize: NSNumber
    @NSManaged var curveDegrees: NSNumber
    @NSManaged var textColorHex: String
    @NSManaged var borderColorHex: String
    @NSManaged var borderSize: NSNumber
    @NSManaged var textModelEntityToPhotoEntity: PhotoEntity?
}

extension TextModelEntity: Identifiable {
    convenience init(id: UUID = UUID(),
                     text: String = "Label",
                     fontName: String = "Arial",
                     fontSize: Int = 32,
                     curveDegrees: Double = 0.0,
                     textColorHex: String = "#FFFFFFFF",
                     borderColorHex: String = "#000000FF",
                     borderSize: Int = 0,
                     textModelEntityToPhotoEntity: PhotoEntity? = nil)
    {
        self.init(context: PersistenceController.shared.container.viewContext)
        self.id = id
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize as NSNumber
        self.curveDegrees = curveDegrees as NSNumber
        self.textColorHex = textColorHex
        self.borderColorHex = borderColorHex
        self.borderSize = borderSize as NSNumber
        self.textModelEntityToPhotoEntity = textModelEntityToPhotoEntity
    }
}
