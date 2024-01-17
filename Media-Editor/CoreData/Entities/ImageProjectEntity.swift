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
    @NSManaged var projectEntityToMediaEntity: Set<PhotoEntity>?
    @NSManaged var frameWidth: NSNumber?
    @NSManaged var frameHeight: NSNumber?
}

extension ImageProjectEntity: Identifiable {
    convenience init(id: UUID, title: String, lastEditDate: Date? = nil, isMovie: Bool, context: NSManagedObjectContext, mediaEntities: Set<PhotoEntity>? = Set<PhotoEntity>()) {
        self.init(context: context)
        self.id = id
        self.title = title
        self.lastEditDate = lastEditDate
        self.isMovie = isMovie
        self.projectEntityToMediaEntity = mediaEntities
    }

    public var media: [PhotoEntity] {
        guard let projectEntityToMediaEntity else { return [] }
        return projectEntityToMediaEntity.sorted(by: { $0.id > $1.id })
    }

    var thumbnailURL: URL {
        return Bundle.main.url(forResource: "ex_image", withExtension: "jpg")!
    }

    var sourcePath: URL {
        return isMovie ? Bundle.main.url(forResource: "ex_image", withExtension: "jpg")! : Bundle.main.url(forResource: "ex_movie", withExtension: "mp4")!
    }

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: lastEditDate ?? Date.now )
    }
    
    func setFrame(width: Int, height: Int) {
        self.frameWidth = NSNumber(value: width)
        self.frameHeight = NSNumber(value: height)
    }
    
    func getFrame() -> (CGFloat, CGFloat) {
        return (self.frameWidth?.doubleValue ?? -1.0, self.frameHeight?.doubleValue ?? -1.0)
    }
    
    var isFrameLandscape: Bool {
        let (width, height) = getFrame()
        return width > height
    }
}
