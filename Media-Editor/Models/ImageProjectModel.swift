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

    @Published var framePixelWidth: CGFloat? {
        willSet {
            guard let newValue else { return }
            imageProjectEntity.frameWidth = NSNumber(value: newValue)
        }
    }

    @Published var framePixelHeight: CGFloat? {
        willSet {
            guard let newValue else { return }
            imageProjectEntity.frameHeight = NSNumber(value: newValue)
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
        if let framePixelWidth = imageProjectEntity.frameWidth?.intValue,
           let framePixelHeight = imageProjectEntity.frameHeight?.intValue {
            self.framePixelWidth = CGFloat(framePixelWidth)
            self.framePixelHeight = CGFloat(framePixelHeight)
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
        var photoEntitiesCopy = photoEntities
        photoEntitiesCopy.insert(photo)
        photoEntities = photoEntitiesCopy
    }
}

extension ImageProjectModel: Equatable {
    static func == (lhs: ImageProjectModel, rhs: ImageProjectModel) -> Bool {
        return lhs.imageProjectEntity.id == rhs.imageProjectEntity.id
    }
}
