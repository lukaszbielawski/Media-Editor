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

    @Published var previewPhoto: CGImage?
    @Published var selectedPhotos = [PHAsset]()
    @Published var libraryPhotos = [PHAsset]()

    @Published var currentTool: (any Tool)?
    @Published var currentFilter: FilterType?
    @Published var currentCategory: FilterCategoryType?
    @Published var originalCGImage: CGImage!

    @Published var workspaceSize: CGSize?

    @Published var plane: PlaneModel = .init()
    @Published var frame: FrameModel = .init()
    @Published var tools: ToolsModel = .init()

    @Published var layerToDelete: LayerModel?
    @Published var activeLayer: LayerModel?

    @Published var projectLayers = [LayerModel]()

    private var latestSnapshot: SnapshotModel!
    @Published var redoModel: [SnapshotModel] = .init()
    @Published var undoModel: [SnapshotModel] = .init()

    @Published var isSnapshotCurrentlyLoading = false
    @Published var isExportSheetPresented = false

    let undoLimit = 50
    let performLayerDragPublisher = PassthroughSubject<CGSize, Never>()
    let showImageExportResultToast = PassthroughSubject<Bool, Never>()
    let layoutChangedSubject = CurrentValueSubject<Void, Never>(())

    var leftFloatingButtonActionType = FloatingButtonActionType.back
    var rightFloatingButtonActionType = FloatingButtonActionType.confirm

    var floatingButtonClickedSubject = PassthroughSubject<FloatingButtonActionType, Never>()

    var centerButtonFunction: (() -> Void)?

    private var cancellable: AnyCancellable?

    private var photoLibraryService = PhotoLibraryService()
    private var photoExporterService = PhotoExporterService()

    var marginedWorkspaceSize: CGSize? {
        guard let totalLowerToolbarHeight = plane.totalLowerToolbarHeight, let workspaceSize
        else { return nil }

        return CGSize(width: workspaceSize.width * (1.0 - 2 * frame.paddingFactor),
                      height: (workspaceSize.height - totalLowerToolbarHeight) * (1.0 - 2 * frame.paddingFactor))
    }

    var isInNewCGImagePreview: Bool {
        if let currentTool = currentTool as? LayerToolType {
            return currentTool == .filters
        } else {
            return false
        }
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

    deinit {
        print("viewmodel deinit")
    }

    func setupAddAssetsToProject() {
        photoLibraryService.requestAuthorization()
        setupSubscription()
    }

    private func setupSubscription() {
        cancellable = photoLibraryService
            .mediaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] assets in
                self.libraryPhotos = assets
            }
    }

    func updateLatestSnapshot() {
        if undoModel.count > undoLimit {
            undoModel.removeFirst()
        }
        redoModel.removeAll()
        undoModel.append(latestSnapshot)
        latestSnapshot = createSnapshot()
        projectModel.lastEditDate = Date.now
        PersistenceController.shared.saveChanges()
        layoutChangedSubject.send()
    }

    func performUndo() {
        guard undoModel.count > 0 else { return }

        let firstSnapshot = createSnapshot()
        loadPreviousProjectLayerData(isUndo: true)
        undoModel.removeLast()
        redoModel.append(firstSnapshot)
        latestSnapshot = createSnapshot()

        // TODO: poprawic logike undo do tych cgimagow
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
        let layers = projectLayers.map { $0.copy(withCGImage: !isInNewCGImagePreview) as! LayerModel }
        let projectModel = projectModel.copy() as! ImageProjectModel
        return .init(layers: layers, projectModel: projectModel)
    }

    func saveNewCGImageOnDisk(for layer: LayerModel) async throws {
        if let imageData = UIImage(cgImage: layer.cgImage).pngData() {
            _ = try await photoLibraryService.saveToDisk(
                data: imageData,
                fileName: layer.fileName)
            print("finished")
        }
    }

    private func loadPreviousProjectLayerData(isUndo: Bool) {
        let previousLayers = (isUndo ? undoModel : redoModel)
        guard previousLayers.count > 0 else { return }

        for previousLayer in previousLayers.last!.layers {
            if let layer = projectLayers.first(where: { $0.fileName == previousLayer.fileName }) {
                layer.positionZ = previousLayer.positionZ
                layer.toDelete = previousLayer.toDelete

                layer.cgImage = previousLayer.cgImage
                Task {
                    try await saveNewCGImageOnDisk(for: previousLayer)
                }

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
        projectModel.lastEditDate = Date.now
        PersistenceController.shared.saveChanges()
        layoutChangedSubject.send()
    }

    func deactivateLayer() {
        disablePreviewCGImage()
        activeLayer = nil
    }

    func disablePreviewCGImage() {
        if isInNewCGImagePreview {
            activeLayer?.cgImage = originalCGImage
        }
    }

    func setupCenterButtonFunction() {
        centerButtonFunction = { [weak self] in
            self?.centerPerspective()
        }
    }

    func centerPerspective() {
        guard let initialPosition = plane.initialPosition,
              let currentPosition = plane.currentPosition else { return }
        let distance = hypot(currentPosition.x - initialPosition.x, currentPosition.y - initialPosition.y)

        let animationDuration: Double = distance / 2000.0 + 0.2

        withAnimation(.easeInOut(duration: animationDuration)) {
            plane.currentPosition = initialPosition
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.linear(duration: 0.2)) { [unowned self] in
                self.plane.scale = 1.0
            }
        }
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

    func updatePlanePosition(newPosition: CGPoint, tolerance: CGFloat? = nil) throws {
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
        objectWillChange.send()
    }

    func swapLayersPositionZ(lhs: LayerModel, rhs: LayerModel) {
        guard let lhsIndex = lhs.positionZ, let rhsIndex = rhs.positionZ else { return }
        lhs.positionZ = abs(rhsIndex) * Int(copysign(-1.0, Double(lhsIndex)))
        rhs.positionZ = abs(lhsIndex) * Int(copysign(-1.0, Double(rhsIndex)))
        updateLatestSnapshot()
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
        try await photoLibraryService
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
    }

    func saveThumbnailToDisk() async {
        guard let framePixelWidth = projectModel.framePixelWidth,
              let framePixelHeight = projectModel.framePixelHeight,
              let marginedWorkspaceWidth = marginedWorkspaceSize?.width else { return }
        do {
            let renderedPhoto = try await photoExporterService.exportLayersToImage(
                photos: projectLayers,
                contextPixelSize: CGSize(width: framePixelWidth, height: framePixelHeight),
                backgroundColor: projectModel.backgroundColor.cgColor!)

            let resizedPhoto = try await photoExporterService.resizePhoto(
                renderedPhoto: renderedPhoto,
                renderSize: .preview,
                photoFormat: .jpeg,
                framePixelWidth: framePixelWidth,
                framePixelHeight: framePixelHeight,
                marginedWorkspaceWidth: marginedWorkspaceWidth)

            guard let imageData = UIImage(cgImage: resizedPhoto).pngData() else {
                throw PhotoExportError.dataRetrieving
            }

            _ = try await photoLibraryService.saveToDisk(
                data: imageData,
                extension: "JPEG",
                folderName: projectModel.imageProjectThumbnailFolderName,
                fileName: projectModel.id!.uuidString)
        } catch {
            print(error)
        }
    }

    func addAssetsToProject() async throws {
        let fileNames = try await photoLibraryService.saveAssetsAndGetFileNames(assets: selectedPhotos)
        try projectModel.insertPhotosEntityToProject(fileNames: fileNames)

        for photoEntity in projectModel.photoEntities
            where !projectLayers.contains(where: { $0.fileName == photoEntity.fileName })
        {
            projectLayers.append(LayerModel(photoEntity: photoEntity))
        }
    }

    func applyFilter() async {
        guard let activeLayer,
              let currentFilter else { return }
        let cgImage = await Task<CGImage?, Never> { [unowned self] in
            let ciImage = CIImage(cgImage: self.originalCGImage.copy()!)

            let filter = currentFilter.createFilter(image: ciImage)

            guard let outputImage = filter.outputImage else { return nil }

            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
            return cgImage
        }.value

        activeLayer.cgImage = cgImage

        objectWillChange.send()
    }

    func renderPhoto(renderSize: RenderSizeType, photoFormat: PhotoFormatType = .png) async {
        guard let framePixelWidth = projectModel.framePixelWidth,
              let framePixelHeight = projectModel.framePixelHeight,
              let marginedWorkspaceWidth = marginedWorkspaceSize?.width else { return }
        do {
            let renderedPhoto = try await photoExporterService.exportLayersToImage(
                photos: projectLayers,
                contextPixelSize: CGSize(width: framePixelWidth, height: framePixelHeight),
                backgroundColor: projectModel.backgroundColor.cgColor!)

            let resizedPhoto = try await photoExporterService.resizePhoto(
                renderedPhoto: renderedPhoto,
                renderSize: renderSize,
                photoFormat: photoFormat,
                framePixelWidth: framePixelWidth,
                framePixelHeight: framePixelHeight,
                marginedWorkspaceWidth: marginedWorkspaceWidth)

            if renderSize == .preview {
                previewPhoto = resizedPhoto
            } else {
                let result = try await photoLibraryService.storeInPhotoAlbumContinuation(
                    resizedPhoto: resizedPhoto,
                    photoFormat: photoFormat)

                if result {
                    HapticService.shared.notify(.success)
                    showImageExportResultToast.send(true)
                } else { HapticService.shared.notify(.error)
                    showImageExportResultToast.send(false)
                }
                isExportSheetPresented = false
            }

        } catch {
            isExportSheetPresented = false
            showImageExportResultToast.send(false)
            print(error)
        }
    }
}
