//
//  ImageProjectEntity.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//
//

import CoreData
import Foundation

public class ImageProjectEntity: NSManagedObject {}

public extension ImageProjectEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ImageProjectEntity> {
        return NSFetchRequest<ImageProjectEntity>(entityName: "ImageProjectEntity")
    }

    @NSManaged var id: UUID?
    @NSManaged var title: String?
    @NSManaged var lastEditDate: Date?
    @NSManaged var isMovie: Bool
    @NSManaged var imageProjectEntityToPhotoEntity: Set<PhotoEntity>?
    @NSManaged var frameWidth: NSNumber?
    @NSManaged var frameHeight: NSNumber?
}

extension ImageProjectEntity: Identifiable {
    convenience init(id: UUID,
                     title: String,
                     lastEditDate: Date? = nil,
                     isMovie: Bool,
                     context: NSManagedObjectContext,
                     mediaEntities: Set<PhotoEntity>? = Set<PhotoEntity>())
    {
        self.init(context: context)
        self.id = id
        self.title = title
        self.lastEditDate = lastEditDate
        self.isMovie = isMovie
        self.imageProjectEntityToPhotoEntity = mediaEntities
        self.frameWidth = nil
        self.frameHeight = nil
    }

    public var media: [PhotoEntity] {
        guard let imageProjectEntityToPhotoEntity else { return [] }
        return imageProjectEntityToPhotoEntity.sorted(by: { $0.id > $1.id })
    }

    var thumbnailURL: URL {
        return Bundle.main.url(forResource: "ex_image", withExtension: "jpg")!
    }

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self.lastEditDate ?? Date.now)
    }
}
