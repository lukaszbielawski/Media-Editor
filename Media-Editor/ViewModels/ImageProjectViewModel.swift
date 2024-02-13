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
    @Published var projectModel: ImageProjectModel

    @Published var selectedPhotos = [PHAsset]()
    @Published var libraryPhotos = [PHAsset]()
    @Published var currentTool: ToolType = .none

    @Published var isImportPhotoViewShown = false
    @Published var isDeleteImageAlertPresented = false
    @Published var centerButtonFunction: (() -> Void)?

    @Published var workspaceSize: CGSize?

    @Published var plane: PlaneModel = .init()
    @Published var frame: FrameModel = .init()
    @Published var tools: ToolsModel = .init()

    @Published var projectLayers = [LayerModel]()
    @Published var layerToDelete: LayerModel?
    @Published var activeLayer: LayerModel?

    private var subscription: AnyCancellable?

    private var photoService = PhotoLibraryService()

    init(projectEntity: ImageProjectEntity) {
        self.projectModel = ImageProjectModel(imageProjectEntity: projectEntity)
        configureNavBar()

        let photoEntities = projectModel.photoEntities

        var isFirst = true
        for photoEntity in photoEntities {
            let layerModel = LayerModel(photoEntity: photoEntity)

            if projectModel.lastEditDate == nil && isFirst {
                isFirst = false
                layerModel.positionZ = 1
                projectLayers.append(layerModel)

                projectModel.frameSize
                    = CGSize(width: layerModel.cgImage.width, height: layerModel.cgImage.height)
                projectModel.lastEditDate = Date.now

                PersistenceController.shared.saveChanges()
            } else {
                projectLayers.append(layerModel)
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

    func calculateLayerSize(layerModel: LayerModel) -> CGSize {
        guard let frameSize = frame.rect?.size,
              let projectFrame = projectModel.frameSize
        else { return .zero }

        let scale = (x: Double(layerModel.cgImage.width) / projectFrame.width,
                     y: Double(layerModel.cgImage.height) / projectFrame.height)

        let layerSize = CGSize(width: frameSize.width * scale.x, height: frameSize.height * scale.y)

        return layerSize
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
        if layerModel.positionZ != nil {
            activeLayer = nil
        } else {
            activeLayer = layerModel
        }

        PersistenceController.shared.saveChanges()
        objectWillChange.send()
    }

    func swapLayersPositionZ(lhs: LayerModel, rhs: LayerModel) {
        guard let lhsIndex = lhs.positionZ, let rhsIndex = rhs.positionZ else { return }
        lhs.positionZ = abs(rhsIndex) * Int(copysign(-1.0, Double(lhsIndex)))
        rhs.positionZ = abs(lhsIndex) * Int(copysign(-1.0, Double(rhsIndex)))

        PersistenceController.shared.saveChanges()
        objectWillChange.send()
    }

    func setupFrameRect() {
        guard let totalLowerToolbarHeight = plane.totalLowerToolbarHeight,
              let workspaceSize,
              let projectFrameSize = projectModel.frameSize
        else { return }

        let (width, height) = (projectFrameSize.width, projectFrameSize.height)
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

    func deleteLayer() {
        guard let photoToDelete = layerToDelete else { return }
        PersistenceController.shared.photoController.delete(for: photoToDelete.fileName)
        projectLayers.removeAll { $0.fileName == photoToDelete.fileName }
        PersistenceController.shared.saveChanges()
        layerToDelete = nil
    }

    func addAssetsToProject() async throws {
        let fileNames = try await photoService.saveAssetsAndGetFileNames(assets: selectedPhotos, for: projectModel.imageProjectEntity)
        try projectModel.imageProjectEntity.insertMediaToProject(fileNames: fileNames)

        for photoEntity in projectModel.photoEntities where !projectLayers.contains(where: { $0.fileName == photoEntity.fileName }) {
            projectLayers.append(LayerModel(photoEntity: photoEntity))
        }
    }
}
