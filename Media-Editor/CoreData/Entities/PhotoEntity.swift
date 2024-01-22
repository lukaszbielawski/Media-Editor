//
//  PhotoEntity+CoreDataProperties.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//
//

import CoreData
import Foundation

public class PhotoEntity: NSManagedObject {}

public extension PhotoEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }

    @NSManaged var fileName: String?
    @NSManaged var positionX: NSNumber?
    @NSManaged var positionY: NSNumber?
    @NSManaged var positionZ: NSNumber?
    @NSManaged var scaleX: NSNumber?
    @NSManaged var scaleY: NSNumber?

    @NSManaged var mediaEntityToProjectEntity: ImageProjectEntity?
}

extension PhotoEntity: Identifiable {
    convenience init(fileName: String,
                     projectEntity: ImageProjectEntity,
                     context: NSManagedObjectContext,
                     scaleX: Double = 1.0,
                     scaleY: Double = 1.0,
                     positionX: Double = 0.0,
                     positionY: Double = 0.0,
                     positionZ: Int? = nil)
    {
        self.init(context: context)
        self.fileName = fileName
        self.mediaEntityToProjectEntity = projectEntity
        self.positionX = NSNumber(value: positionX)
        self.positionY = NSNumber(value: positionY)

        if let positionZ {
            self.positionZ = NSNumber(value: positionZ)
        }
        self.scaleX = NSNumber(value: scaleX)
        self.scaleY = NSNumber(value: scaleY)
    }
}

extension PhotoEntity {
    var absoluteFilePath: String {
        let mediaDirectoryPath: URL =
            FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("UserMedia")
        return mediaDirectoryPath
            .appendingPathComponent(self.fileName!)
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
    }
}
