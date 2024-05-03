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
    @NSManaged var imageProjectEntityToPhotoEntity: Set<PhotoEntity>?
    @NSManaged var frameWidth: NSNumber?
    @NSManaged var frameHeight: NSNumber?
    @NSManaged var backgroundColorHex: String
}

extension ImageProjectEntity: Identifiable {
    convenience init(id: UUID,
                     title: String,
                     lastEditDate: Date? = nil,
                     backgroundColorHex: String = "#FFFFFF00",
                     mediaEntities: Set<PhotoEntity>? = Set<PhotoEntity>())
    {
        self.init(context: PersistenceController.shared.container.viewContext)
        self.id = id
        self.title = title
        self.lastEditDate = lastEditDate
        self.backgroundColorHex = backgroundColorHex
        self.imageProjectEntityToPhotoEntity = mediaEntities
        self.frameWidth = nil
        self.frameHeight = nil
    }

    public var media: [PhotoEntity] {
        guard let imageProjectEntityToPhotoEntity else { return [] }
        return imageProjectEntityToPhotoEntity.sorted(by: { $0.id > $1.id })
    }

    var absoluteThumbnailFilePath: String {
        let uuid = id!.uuidString
        let mediaDirectoryPath: URL =
            FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("ProjectThumbnails")
        return mediaDirectoryPath
            .appendingPathComponent(uuid)
            .absoluteString.replacingOccurrences(of: "file://", with: "")
    }

    var thumbnailURL: URL {
        return URL(string: "file://" + absoluteThumbnailFilePath)!.appendingPathExtension("JPEG")
    }

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self.lastEditDate ?? Date.now)
    }
}
