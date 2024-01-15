//
//  MediaEntity+CoreDataProperties.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//
//

import CoreData
import Foundation

@objc(MediaEntity)
public class MediaEntity: NSManagedObject {}

public extension MediaEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<MediaEntity> {
        return NSFetchRequest<MediaEntity>(entityName: "MediaEntity")
    }

    @NSManaged var fileName: String?
    @NSManaged var mediaEntityToProjectEntity: ProjectEntity?
}

extension MediaEntity: Identifiable {
    convenience init(fileName: String, projectEntity: ProjectEntity, context: NSManagedObjectContext) {
        self.init(context: context)
        self.fileName = fileName
        self.mediaEntityToProjectEntity = projectEntity
    }
}

extension MediaEntity {
    var absoluteFilePath: String {
        print(self.fileName)
        let mediaDirectoryPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("UserMedia")
        return mediaDirectoryPath.appendingPathComponent(self.fileName!).absoluteString.replacingOccurrences(of: "file://", with: "")
    }
}
