//
//  ImageProjectViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Combine
import Foundation
import Photos
import SwiftUI

@MainActor
final class ImageProjectViewModel: ObservableObject {
    @Published var project: ImageProjectEntity
    @Published var projectPhotos = [PhotoModel]()
    @Published var selectedPhotos = [PHAsset]()
    @Published var libraryPhotos = [PHAsset]()
    @Published var currentTool: ToolType = .none

    @Published var isImportPhotoViewShown: Bool = false

    private var subscription: AnyCancellable?

    private var photoService = PhotoLibraryService()

    init(project: ImageProjectEntity) {
        self.project = project

        if let mediaEntities = project.projectEntityToMediaEntity {
            var isFirst = true
            for entity in mediaEntities {
                if project.lastEditDate == nil && isFirst {
                    entity.positionZ = 0

                    isFirst = false
                    let model = PhotoModel(photoEntity: entity)
                    projectPhotos.append(model)

                    project.setFrame(width: model.cgImage.width, height: model.cgImage.height)
                    project.lastEditDate = Date.now

//                    try? PersistenceController.shared.container.viewContext.save()
                } else {
                    projectPhotos.append(PhotoModel(photoEntity: entity))
                }
            }
        }
    }

    func setupAddAssetsToProject() {
        photoService.requestAuthorization(projectType: [ProjectType.photo])
        setupSubscription()
    }

    private func setupSubscription() {
        subscription = photoService
            .mediaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] assets in
                self.libraryPhotos = assets
            }
    }

    func fetchPhoto(for asset: PHAsset,
                    desiredSize: CGSize,
                    contentMode: PHImageContentMode = .default) async throws -> UIImage
    {
        try await photoService
            .fetchThumbnail(for: asset.localIdentifier,
                            desiredSize: desiredSize,
                            contentMode: contentMode)
    }

    func toggleImageSelection(for asset: PHAsset) -> Bool {
        let index = selectedPhotos.firstIndex(of: asset)

        if let index {
            selectedPhotos.remove(at: index)
        } else {
            selectedPhotos.append(asset)
        }
        objectWillChange.send()
        return index == nil
    }

    func addAssetsToProject() async throws {
        let fileNames = try await photoService.saveAssetsAndGetFileNames(assets: selectedPhotos, for: project)
        try photoService.insertMediaToProject(projectEntity: project, fileNames: fileNames)

        guard let entities = project.projectEntityToMediaEntity else { return }
        for entity in entities where !projectPhotos.contains(where: { $0.fileName == entity.fileName }) {
            projectPhotos.append(PhotoModel(photoEntity: entity))
        }
    }
}
