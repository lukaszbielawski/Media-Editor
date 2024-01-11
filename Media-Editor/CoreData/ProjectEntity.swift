//
//  ProjectEntity.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//
//

import CoreData
import Foundation

public class ProjectEntity: NSManagedObject {}

public extension ProjectEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        return NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    }

    @NSManaged var id: UUID?
    @NSManaged var title: String?
    @NSManaged var lastEditDate: Date?
    @NSManaged var isMovie: Bool
    @NSManaged var projectEntityToMediaEntity: Set<MediaEntity>?
}

extension ProjectEntity: Identifiable {
    convenience init(id: UUID, title: String, lastEditDate: Date, isMovie: Bool, context: NSManagedObjectContext, mediaEntities: Set<MediaEntity>? = Set<MediaEntity>()) {
        self.init(context: context)
        self.id = id
        self.title = title
        self.lastEditDate = lastEditDate
        self.isMovie = isMovie
        self.projectEntityToMediaEntity = mediaEntities
    }

    public var media: [MediaEntity] {
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
        return dateFormatter.string(from: lastEditDate!)
    }
}
