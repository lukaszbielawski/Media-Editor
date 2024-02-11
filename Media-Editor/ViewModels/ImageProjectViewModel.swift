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

    @Published var selectedPhotos = [PHAsset]()
    @Published var libraryPhotos = [PHAsset]()
    @Published var currentTool: ToolType = .none

    @Published var isImportPhotoViewShown: Bool = false
    @Published var centerButtonFunction: (() -> Void)?

    @Published var workspaceSize: CGSize?

    @Published var plane: PlaneModel = .init()
    @Published var frame: FrameModel = .init()

    @Published var projectLayers = [LayerModel]()
    @Published var layerToDelete: LayerModel?
    @Published var activeLayer: LayerModel?

    private var subscription: AnyCancellable?

    private var photoService = PhotoLibraryService()

    init(project: ImageProjectEntity) {
        self.project = project

        if let mediaEntities = project.imageProjectEntityToPhotoEntity {
            var isFirst = true
            for entity in mediaEntities {
                if project.lastEditDate == nil && isFirst {
                    isFirst = false
                    let model = LayerModel(photoEntity: entity)
                    projectLayers.append(model)
                    model.positionZ = 1

                    project.setFrame(width: model.cgImage.width, height: model.cgImage.height)
                    project.lastEditDate = Date.now

                    PersistenceController.shared.saveChanges()
                } else {
                    projectLayers.append(LayerModel(photoEntity: entity))
                }
            }
        }
        configureNavBar()
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

    func configureNavBar() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color(.image))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.tint]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.tint]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func updateFramePosition(newPosition: CGPoint, tolerance: CGFloat? = nil) throws {
        guard let furthestPlanePointAllowed = plane.furthestPlanePointAllowed,
              let frameViewRect = frame.rect,
              let totalNavBarHeight = plane.totalNavBarHeight,
              let totalLowerToolbarHeight = plane.totalLowerToolbarHeight
        else {
            return
        }
        let maxOffset: Double = tolerance ?? frame.padding

        let (newX, newY) = (newPosition.x, newPosition.y)
        let (maxX, maxY) =
            (furthestPlanePointAllowed.x + frameViewRect.width / 2,
             furthestPlanePointAllowed.y -
                 totalLowerToolbarHeight + frameViewRect.height / 2)
        let (minX, minY) =
            (-frameViewRect.width / 2,
             -frameViewRect.height / 2 + totalNavBarHeight)

        if minX + maxOffset > newX {
            let diff = minX + maxOffset - newX
            throw EdgeOverflowError.leading(offset: diff)
        } else if maxX - maxOffset < newX {
            let diff = newX - maxX + maxOffset

            throw EdgeOverflowError.trailing(offset: diff)
        }

        if minY + maxOffset > newY {
            let diff = minY + maxOffset - newY
            throw EdgeOverflowError.top(offset: diff)
        } else if maxY - maxOffset < newY {
            let diff = newY - maxY + maxOffset
            throw EdgeOverflowError.bottom(offset: diff)
        }
        plane.currentPosition = newPosition
    }

    func showLayerOnScreen(layerModel: LayerModel) {
        layerModel.positionZ = (projectLayers.compactMap { $0.positionZ }.max() ?? 0) + 1
        PersistenceController.shared.saveChanges()
        activeLayer = layerModel
    }

    func setupFrameRect() {
        guard let totalLowerToolbarHeight = plane.totalLowerToolbarHeight, let workspaceSize else { return }

        let (width, height) = (project.getSize().width, project.getSize().height)
        let (geoWidth, geoHeight) =
            (workspaceSize.width * (1.0 - 2 * frame.paddingFactor),
             (workspaceSize.height - totalLowerToolbarHeight) * (1.0 - 2 * frame.paddingFactor))
        let aspectRatio = height / width
        let geoAspectRatio = geoHeight / geoWidth

        let frameSize = if aspectRatio < geoAspectRatio {
            CGSize(width: geoWidth, height: geoWidth * aspectRatio)
        } else {
            CGSize(width: geoHeight / aspectRatio, height: geoHeight)
        }

        frame.rect = CGRect(origin: .zero,
                            size: frameSize)
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
        for entity in entities where !projectLayers.contains(where: { $0.fileName == entity.fileName }) {
            projectLayers.append(LayerModel(photoEntity: entity))
        }
    }
}
