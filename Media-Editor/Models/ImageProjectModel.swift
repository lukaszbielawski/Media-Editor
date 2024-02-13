//
//  ProjectModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/02/2024.
//

import Foundation

@MainActor
final class ImageProjectModel: ObservableObject {
    private let imageProjectEntity: ImageProjectEntity
    let isMovie: Bool

    @Published var title: String? {
        willSet { imageProjectEntity.title = newValue }
    }

    @Published var lastEditDate: Date? {
        willSet { imageProjectEntity.lastEditDate = newValue }
    }

    @Published var photoEntities: Set<PhotoEntity> {
        willSet { imageProjectEntity.imageProjectEntityToPhotoEntity = newValue }
    }

    @Published var framePixelSize: CGSize? {
        willSet {
            guard let newValue else { return }
            imageProjectEntity.frameWidth = NSNumber(value: newValue.width)
            imageProjectEntity.frameHeight = NSNumber(value: newValue.height)
        }
    }

    init(imageProjectEntity: ImageProjectEntity) {
        self.imageProjectEntity = imageProjectEntity

        self.title = imageProjectEntity.title
        self.lastEditDate = imageProjectEntity.lastEditDate
        self.isMovie = false
        self.photoEntities = imageProjectEntity
            .imageProjectEntityToPhotoEntity
            ?? Set<PhotoEntity>()
        if let frameWidth = imageProjectEntity.frameWidth?.intValue,
           let frameHeight = imageProjectEntity.frameHeight?.intValue
        {
            self.framePixelSize = CGSize(width: frameWidth, height: frameHeight)
        }
    }

    func insertPhotosEntityToProject(fileNames: [String]) throws {
        let container = PersistenceController.shared.container

        for fileName in fileNames {
            let photoEntity = PhotoEntity(fileName: fileName,
                                          projectEntity: imageProjectEntity,
                                          context: container.viewContext)

            insertPhotosToEntity(photo: photoEntity)
        }

        PersistenceController.shared.saveChanges()
    }

    func insertPhotosToEntity(photo: PhotoEntity) {
        var photoEntitiesCopy = self.photoEntities
        photoEntitiesCopy.insert(photo)
        self.photoEntities = photoEntitiesCopy
    }
}

extension ImageProjectModel: Equatable {
    static func == (lhs: ImageProjectModel, rhs: ImageProjectModel) -> Bool {
        return lhs.imageProjectEntity.id == rhs.imageProjectEntity.id
    }
    

}
