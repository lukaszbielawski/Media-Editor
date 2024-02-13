//
//  ProjectModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/02/2024.
//

import Foundation

@MainActor
final class ImageProjectModel: ObservableObject {
    let imageProjectEntity: ImageProjectEntity

    @Published var title: String?
    @Published var lastEditDate: Date?
    @Published var isMovie: Bool?
    @Published var photoEntities: Set<PhotoEntity>

    @Published var frameSize: CGSize? {
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
            self.frameSize = CGSize(width: frameWidth, height: frameHeight)
        }
    }
}
