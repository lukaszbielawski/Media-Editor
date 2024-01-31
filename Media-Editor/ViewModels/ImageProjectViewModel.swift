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
    @Published var photoToDelete: PhotoModel?
    @Published var isImportPhotoViewShown: Bool = false
    @Published var activeLayerPhoto: PhotoModel?

    private var subscription: AnyCancellable?

    private var photoService = PhotoLibraryService()

    init(project: ImageProjectEntity) {
        self.project = project

        if let mediaEntities = project.imageProjectEntityToPhotoEntity {
            var isFirst = true
            for entity in mediaEntities {
                if project.lastEditDate == nil && isFirst {
                    entity.positionZ = 1

                    isFirst = false
                    let model = PhotoModel(photoEntity: entity)
                    projectPhotos.append(model)

                    project.setFrame(width: model.cgImage.width, height: model.cgImage.height)
                    project.lastEditDate = Date.now

                    PersistenceController.shared.saveChanges()
                } else {
                    projectPhotos.append(PhotoModel(photoEntity: entity))
                }
            }
        }
    }

    func addPhotoLayer(photo: PhotoModel) {
        var index = projectPhotos.firstIndex { $0.id == photo.id }
        guard let index else { return }
        projectPhotos[index].positionZ = (projectPhotos.compactMap { $0.positionZ }.max() ?? 0) + 1
        print("xd")
        projectPhotos[index].updateEntity()
        PersistenceController.shared.saveChanges()
        activeLayerPhoto = projectPhotos[index]
    }

    func calculateLayerSize(photo: PhotoModel,
                            geoSize: CGSize,
                            framePaddingFactor: Double,
                            totalLowerToolbarHeight: Double) -> CGSize
    {
        let frameSize = calculateFrameSize(geoSize: geoSize,
                                           framePaddingFactor: framePaddingFactor,
                                           totalLowerToolbarHeight: totalLowerToolbarHeight)

        let projectFrame = project.getSize()

        let scale = (x: Double(photo.cgImage.width) / projectFrame.width,
                     y: Double(photo.cgImage.height) / projectFrame.height)

        let layerSize = CGSize(width: frameSize.width * scale.x, height: frameSize.height * scale.y)

        return layerSize
    }

    func calculateFrameSize(geoSize: CGSize, framePaddingFactor: Double, totalLowerToolbarHeight: Double) -> CGSize {
        let (width, height) = (project.getSize().width, project.getSize().height)
        let (geoWidth, geoHeight) =
            (geoSize.width * (1.0 - 2 * framePaddingFactor),
             (geoSize.height - totalLowerToolbarHeight) * (1.0 - 2 * framePaddingFactor))
        let aspectRatio = height / width
        let geoAspectRatio = geoHeight / geoWidth

        if aspectRatio < geoAspectRatio {
            return CGSize(width: geoWidth,
                          height: geoWidth * aspectRatio)
        } else {
            return CGSize(width: geoHeight / aspectRatio, height: geoHeight)
        }
    }

    func calculateFrameRect(frameSize: CGSize, geo: GeometryProxy, totalLowerToolbarHeight: Double) -> CGRect {
        let centerPoint =
            CGPoint(x: geo.frame(in: .global).midX,
                    y: geo.frame(in: .global).midY - totalLowerToolbarHeight * 0.5)

        let topLeftCorner =
            CGPoint(x: centerPoint.x - frameSize.width * 0.5,
                    y: centerPoint.y - frameSize.height * 0.5)

        return CGRect(origin: topLeftCorner,
                      size: frameSize)
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

        guard let entities = project.imageProjectEntityToPhotoEntity else { return }
        for entity in entities where !projectPhotos.contains(where: { $0.fileName == entity.fileName }) {
            projectPhotos.append(PhotoModel(photoEntity: entity))
        }
    }
}
