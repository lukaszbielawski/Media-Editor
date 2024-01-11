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

    @NSManaged var filePath: String?
    @NSManaged var mediaEntityToProjectEntity: ProjectEntity?
}

extension MediaEntity: Identifiable {
    convenience init(filePath: String, projectEntity: ProjectEntity, context: NSManagedObjectContext) {
        self.init(context: context)
        self.filePath = filePath
        self.mediaEntityToProjectEntity = projectEntity
    }
}
