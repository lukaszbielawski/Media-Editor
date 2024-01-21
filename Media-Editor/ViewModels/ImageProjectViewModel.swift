//
//  ImageProjectViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Foundation
import SwiftUI

@MainActor
final class ImageProjectViewModel: ObservableObject {
    @Published var project: ImageProjectEntity
    @Published var media = [PhotoModel]()
    @Published var currentTool: ToolType = .none

    init(project: ImageProjectEntity) {
        self.project = project

        if let mediaEntities = project.projectEntityToMediaEntity {
            var isFirst = true
            for entity in mediaEntities {
                if project.lastEditDate == nil && isFirst {
                    entity.positionZ = 0

                    isFirst = false
                    let model = PhotoModel(photoEntity: entity)
                    media.append(model)

                    project.setFrame(width: model.cgImage.width, height: model.cgImage.height)
                    project.lastEditDate = Date.now

//                    try? PersistenceController.shared.container.viewContext.save()
                } else {
                    media.append(PhotoModel(photoEntity: entity))
                }
            }
        }
    }
}
