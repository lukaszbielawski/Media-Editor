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
    @Published var currentTool: (any Tool)?
    @Published var currentFilter: FilterType?

    @Published var workspaceSize: CGSize?

    @Published var plane: PlaneModel = .init()
    @Published var frame: FrameModel = .init()
    @Published var tools: ToolsModel = .init()

    @Published var layerToDelete: LayerModel?
    @Published var activeLayer: LayerModel?

    @Published var projectFilters: [FilterType] = .init()

    @Published var projectLayers = [LayerModel]()

    var latestSnapshot: SnapshotModel!
    @Published var redoModel: [SnapshotModel] = .init()
    @Published var undoModel: [SnapshotModel] = .init()

    @Published var isSnapshotCurrentlyLoading = false

    let performLayerDragPublisher = PassthroughSubject<CGSize, Never>()

    private var subscriptions: [AnyCancellable] = .init()

    private var photoService = PhotoLibraryService()

    var marginedWorkspaceSize: CGSize? {
        guard let totalLowerToolbarHeight = plane.totalLowerToolbarHeight, let workspaceSize
        else { return nil }

        return CGSize(width: workspaceSize.width * (1.0 - 2 * frame.paddingFactor),
                      height: (workspaceSize.height - totalLowerToolbarHeight) * (1.0 - 2 * frame.paddingFactor))
    }

    typealias PathPoints = (startPoint: CGPoint, endPoint: CGPoint)

    init(projectEntity: ImageProjectEntity) {
        projectModel = ImageProjectModel(imageProjectEntity: projectEntity)
        configureNavBar()

        let photoEntities = projectModel.photoEntities

        var isFirst = true

        for photoEntity in photoEntities {
            let layerModel = LayerModel(photoEntity: photoEntity)
            if let toDelete = layerModel.toDelete, toDelete {
                deletePhotoEntity(photoEntity: photoEntity)
                projectModel.photoEntities.remove(photoEntity)
            } else if projectModel.lastEditDate == nil && isFirst {
                isFirst = false
                layerModel.positionZ = 1
                projectLayers.append(layerModel)

                projectModel.framePixelWidth = CGFloat(layerModel.cgImage.width)
                projectModel.framePixelHeight = CGFloat(layerModel.cgImage.height)
                projectModel.lastEditDate = Date.now

                PersistenceController.shared.saveChanges()
            } else {
                projectLayers.append(layerModel)
            }
        }
        latestSnapshot = createSnapshot()
    }

    func setupAddAssetsToProject() {
        photoService.requestAuthorization(projectType: [.photo])
        setupSubscription()
    }

    private func setupSubscription() {
        photoService
            .mediaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] assets in
                self.libraryPhotos = assets
            }.store(in: &subscriptions)
    }

    func updateLatestSnapshot() {
        if undoModel.count > 5 {
            undoModel.removeFirst()
        }
        redoModel.removeAll()
        undoModel.append(latestSnapshot)
        latestSnapshot = createSnapshot()
    }

    func performUndo() {
        guard undoModel.count > 0 else { return }

        let firstSnapshot = createSnapshot()
        loadPreviousProjectLayerData(isUndo: true)
        undoModel.removeLast()
        redoModel.append(firstSnapshot)
        latestSnapshot = createSnapshot()
    }

    func performRedo() {
        guard redoModel.count > 0 else { return }

        let projectLayerCopy = createSnapshot()
        loadPreviousProjectLayerData(isUndo: false)
        redoModel.removeLast()
        undoModel.append(projectLayerCopy)
        latestSnapshot = createSnapshot()
    }

    private func createSnapshot() -> SnapshotModel {
        let layers = projectLayers.map { $0.copy() as! LayerModel }
        let projectModel = projectModel.copy() as! ImageProjectModel
        return .init(layers: layers, projectModel: projectModel)
    }

    private func loadPreviousProjectLayerData(isUndo: Bool) {
        let previousLayers = (isUndo ? undoModel : redoModel)
        guard previousLayers.count > 0 else { return }

        for previousLayer in previousLayers.last!.layers {
            if let layer = projectLayers.first(where: { $0.fileName == previousLayer.fileName }) {
                layer.cgImage = previousLayer.cgImage
                layer.positionZ = previousLayer.positionZ
                layer.toDelete = previousLayer.toDelete

                let distanceDiff = hypot(layer.position!.x - previousLayer.position!.x,
                                         layer.position!.y - previousLayer.position!.y)
                let animationDuration: Double = distanceDiff / 2000.0 + 0.2

                withAnimation(.easeInOut(duration: animationDuration)) {
                    layer.position = previousLayer.position
                }
                withAnimation(.easeInOut(duration: 0.35)) {
                    layer.rotation = previousLayer.rotation
                    layer.scaleX = previousLayer.scaleX
                    layer.scaleY = previousLayer.scaleY
                    layer.size = self.calculateLayerSize(layerModel: previousLayer)
                }

            } else {
                projectLayers.append(previousLayer)
            }
        }
        let previousProjectModel = previousLayers.last!.projectModel
        withAnimation(.easeInOut(duration: 0.35)) {
            projectModel.backgroundColor = previousProjectModel.backgroundColor
            projectModel.framePixelWidth = previousProjectModel.framePixelWidth
            projectModel.framePixelHeight = previousProjectModel.framePixelHeight
            recalculateFrameAndLayersGeometry()
        }
        PersistenceController.shared.saveChanges()
    }

    func calculateLayerSize(layerModel: LayerModel) -> CGSize {
        guard let frameSize = frame.rect?.size,
              let projectPixelFrameWidth = projectModel.framePixelWidth,
              let projectPixelFrameHeight = projectModel.framePixelHeight
        else { return .zero }

        let validatedProjectPixelFrameWidth =
            max(min(projectPixelFrameWidth, CGFloat(frame.maxPixels)),
                CGFloat(frame.minPixels))

        let validatedProjectPixelFrameHeight =
            max(min(projectPixelFrameHeight, CGFloat(frame.maxPixels)),
                CGFloat(frame.minPixels))

        let scale = (x: Double(layerModel.cgImage.width) / validatedProjectPixelFrameWidth,
                     y: Double(layerModel.cgImage.height) / validatedProjectPixelFrameHeight)

        let layerSize = CGSize(width: frameSize.width * scale.x, height: frameSize.height * scale.y)

        return layerSize
    }

    func recalculateFrameAndLayersGeometry() {
        setupFrameRect()

        for layer in projectLayers {
            layer.size = calculateLayerSize(layerModel: layer)
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

    func calculatePathPoints() -> (xPoints: PathPoints?, yPoints: PathPoints?) {
        guard let workspaceSize, let planePosition = plane.currentPosition else { return (nil, nil) }

        var xPoints: PathPoints?
        var yPoints: PathPoints?

        if let lineXPosition = plane.lineXPosition {
            let startPoint = CGPoint(x: lineXPosition + planePosition.x, y: 0)
            let endPoint = CGPoint(x: lineXPosition + planePosition.x, y: workspaceSize.height)
            xPoints = PathPoints(startPoint: startPoint, endPoint: endPoint)
        }

        if let lineYPosition = plane.lineYPosition {
            let startPoint = CGPoint(x: 0, y: lineYPosition + planePosition.y)
            let endPoint = CGPoint(x: workspaceSize.width, y: lineYPosition + planePosition.y)
            yPoints = PathPoints(startPoint: startPoint, endPoint: endPoint)
        }

        return (xPoints: xPoints, yPoints: yPoints)
    }

    func showLayerOnScreen(layerModel: LayerModel) {
        layerModel.positionZ = (projectLayers.compactMap { $0.positionZ }.max() ?? 0) + 1
        layerModel.toDelete = false
        if layerModel.positionZ != nil {
            activeLayer = nil
        } else {
            activeLayer = layerModel
        }
        updateLatestSnapshot()
        PersistenceController.shared.saveChanges()
        objectWillChange.send()
    }

    func swapLayersPositionZ(lhs: LayerModel, rhs: LayerModel) {
        guard let lhsIndex = lhs.positionZ, let rhsIndex = rhs.positionZ else { return }
        updateLatestSnapshot()
        lhs.positionZ = abs(rhsIndex) * Int(copysign(-1.0, Double(lhsIndex)))
        rhs.positionZ = abs(lhsIndex) * Int(copysign(-1.0, Double(rhsIndex)))

        PersistenceController.shared.saveChanges()
        objectWillChange.send()
    }

    func setupFrameRect() {
        guard let projectPixelFrameWidth = projectModel.framePixelWidth,
              let projectPixelFrameHeight = projectModel.framePixelHeight,
              let marginedWorkspaceSize
        else { return }

        let validatedProjectPixelFrameWidth =
            max(min(projectPixelFrameWidth, CGFloat(frame.maxPixels)),
                CGFloat(frame.minPixels))

        let validatedProjectPixelFrameHeight =
            max(min(projectPixelFrameHeight, CGFloat(frame.maxPixels)),
                CGFloat(frame.minPixels))

        let aspectRatio = validatedProjectPixelFrameHeight / validatedProjectPixelFrameWidth
        let workspaceAspectRatio = marginedWorkspaceSize.height / marginedWorkspaceSize.width

        let frameSize = if aspectRatio < workspaceAspectRatio {
            CGSize(width: marginedWorkspaceSize.width, height: marginedWorkspaceSize.width * aspectRatio)
        } else {
            CGSize(width: marginedWorkspaceSize.height / aspectRatio, height: marginedWorkspaceSize.height)
        }

        frame.rect = CGRect(origin: CGPoint(x: -frameSize.width * 0.5, y: -frameSize.height * 0.5),
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

    private func deletePhotoEntity(photoEntity: PhotoEntity) {
        guard let fileName = photoEntity.fileName else { return }
        PersistenceController.shared.photoController.delete(for: fileName)
        PersistenceController.shared.saveChanges()
    }

    func deleteLayer() {
        guard let layerToDelete else { return }
        layerToDelete.toDelete = true
        layerToDelete.positionZ = nil
        updateLatestSnapshot()
        PersistenceController.shared.saveChanges()
    }

    func addAssetsToProject() async throws {
        let fileNames = try await photoService.saveAssetsAndGetFileNames(assets: selectedPhotos)
        try projectModel.insertPhotosEntityToProject(fileNames: fileNames)

        for photoEntity in projectModel.photoEntities
            where !projectLayers.contains(where: { $0.fileName == photoEntity.fileName })
        {
            projectLayers.append(LayerModel(photoEntity: photoEntity))
        }
    }

    func exportProjectToPhotoLibrary() {
        guard let framePixelWidth = projectModel.framePixelWidth,
              let framePixelHeight = projectModel.framePixelHeight else { return }
        Task { photoService.exportPhotosToFile(
            photos: projectLayers,
            contextPixelSize: CGSize(width: framePixelWidth, height: framePixelHeight),
            backgroundColor: projectModel.backgroundColor.cgColor!,
            format: tools.photoExportFormat)
        }
    }
}
