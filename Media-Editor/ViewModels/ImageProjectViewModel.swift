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
    @Published var currentCropRatio: CropRatioType = .any
    @Published var currentCropShape: CropShapeType = .rectangle
    @Published var currentLayerBackgroundColor: Color = .clear
    @Published var originalCGImage: CGImage!

    @Published var workspaceSize: CGSize?

    @Published var plane: PlaneModel = .init()
    @Published var frame: FrameModel = .init()
    @Published var tools: ToolsModel = .init()

    @Published var layerToDelete: LayerModel?
    @Published var activeLayer: LayerModel?

    @Published var projectLayers = [LayerModel]()

    @Published var redoModel: [SnapshotModel] = .init()
    @Published var undoModel: [SnapshotModel] = .init()

    @Published var layersToMerge: [LayerModel] = .init()

    @Published var isSnapshotCurrentlyLoading = false
    @Published var isExportSheetPresented = false

    private var latestSnapshot: SnapshotModel!
    let undoLimit = 50

    let performLayerDragPublisher = PassthroughSubject<CGSize, Never>()
    let showImageExportResultToast = PassthroughSubject<Bool, Never>()
    let layoutChangedSubject = CurrentValueSubject<Void, Never>(())
    let filterChangedSubject = PassthroughSubject<Void, Never>()
    let performToolActionSubject = PassthroughSubject<any Tool, Never>()
    var floatingButtonClickedSubject = PassthroughSubject<FloatingButtonActionType, Never>()

    var leftFloatingButtonActionType = FloatingButtonActionType.back
    var rightFloatingButtonActionType = FloatingButtonActionType.confirm

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
        if let currentTool = currentTool as? LayerToolType, currentTool == .filters || currentTool == .background {
            return true
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
            if photoEntity.toDelete {
                deletePhotoEntity(photoEntity: photoEntity)
                projectModel.photoEntities.remove(photoEntity)
            } else {
                let layerModel = LayerModel(photoEntity: photoEntity)
                if projectModel.lastEditDate == nil && isFirst {
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
        }
        latestSnapshot = createSnapshot()
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

    nonisolated func saveNewCGImageOnDisk(fileName: String, cgImage: CGImage!) async throws {
        if let imageData = UIImage(cgImage: cgImage).pngData() {
            _ = try await photoLibraryService.saveToDisk(
                data: imageData,
                fileName: fileName)
        }
    }

    private func loadPreviousProjectLayerData(isUndo: Bool) {
        let previousLayers = (isUndo ? undoModel : redoModel)
        guard previousLayers.count > 0 else { return }

        let loadedIDs = previousLayers.last!.layers.map { $0.id }
        let toRemoveIDs = projectLayers.filter { !loadedIDs.contains($0.fileName) }.map { $0.id }

        if let activeLayerID = activeLayer?.id, toRemoveIDs.contains(activeLayerID) {
            deactivateLayer()
        }

        projectLayers.filter { toRemoveIDs.contains($0.id) }.forEach { layerToDelete in
            layerToDelete.positionZ = nil
            layerToDelete.toDelete = true
        }

        for previousLayer in previousLayers.last!.layers {
            if let layer = projectLayers.first(where: { $0.fileName == previousLayer.fileName }) {
                layer.positionZ = previousLayer.positionZ
                layer.toDelete = previousLayer.toDelete

                layer.cgImage = previousLayer.cgImage

                Task { [unowned self] in
                    try await self.saveNewCGImageOnDisk(
                        fileName: previousLayer.fileName,
                        cgImage: previousLayer.cgImage)
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

    func copyAndAppend() async {
        guard let activeLayer else { return }
        let layerCopy = activeLayer.copy(withCGImage: true) as! LayerModel
        try? await createNewEntity(from: layerCopy)
    }

    func createNewEntity(from layer: LayerModel) async throws {
        let projectEntity = projectModel.imageProjectEntity

        guard let dotIndex = layer.fileName.lastIndex(of: ".") else { return }
        let fileExtension = layer.fileName.suffix(from: dotIndex)

        let newEntityFileName = UUID().uuidString + fileExtension

        try await saveNewCGImageOnDisk(fileName: newEntityFileName, cgImage: layer.cgImage)

        let newEntity = PhotoEntity(fileName: newEntityFileName, projectEntity: projectEntity)

        let newLayer = LayerModel(photoEntity: newEntity)

        newLayer.position = layer.position
        newLayer.positionZ = layer.positionZ
        newLayer.rotation = layer.rotation
        newLayer.scaleX = layer.scaleX
        newLayer.scaleY = layer.scaleY
        newLayer.size = layer.size
        newLayer.toDelete = layer.toDelete
        newLayer.cgImage = layer.cgImage

        newEntity.photoEntityToImageProjectEntity = projectEntity

        projectLayers.append(newLayer)

        showLayerOnScreen(layerModel: newLayer)
    }

    func calculateBoundsForMergedLayers() -> (layerRect: CGRect?, pixelSize: CGSize?) {
        var minX, minY, maxX, maxY: Double?

        var minPixelToDigitalWidthRatio: CGFloat?
        var minPixelToDigitalHeightRatio: CGFloat?
        var maxPixelToDigitalWidthRatio: CGFloat?
        var maxPixelToDigitalHeightRatio: CGFloat?

        for layer in layersToMerge {
            let (topLeftX, topLeftY) = (layer.topLeftApexPosition().x * layer.pixelToDigitalWidthRatio,
                                        layer.topLeftApexPosition().y * layer.pixelToDigitalHeightRatio)
            let (topRightX, topRightY) = (layer.topRightApexPosition().x * layer.pixelToDigitalWidthRatio,
                                          layer.topRightApexPosition().y * layer.pixelToDigitalHeightRatio)
            let (bottomLeftX, bottomLeftY) = (layer.bottomLeftApexPosition().x * layer.pixelToDigitalWidthRatio,
                                              layer.bottomLeftApexPosition().y * layer.pixelToDigitalHeightRatio)
            let (bottomRightX, bottomRightY) = (layer.bottomRightApexPosition().x * layer.pixelToDigitalWidthRatio,
                                                layer.bottomRightApexPosition().y * layer.pixelToDigitalHeightRatio)

            let prevMinX = minX
            let prevMinY = minY
            let prevMaxX = maxX
            let prevMaxY = maxY

            minX = min(minX ?? Double(Int.max), topLeftX, topRightX, bottomLeftX, bottomRightX)
            minY = min(minY ?? Double(Int.max), topLeftY, topRightY, bottomLeftY, bottomRightY)
            maxX = max(maxX ?? Double(Int.min), topLeftX, topRightX, bottomLeftX, bottomRightX)
            maxY = max(maxY ?? Double(Int.min), topLeftY, topRightY, bottomLeftY, bottomRightY)

            if prevMinX != minX {
                minPixelToDigitalWidthRatio = layer.pixelToDigitalWidthRatio
            }
            if prevMaxX != maxX {
                maxPixelToDigitalWidthRatio = layer.pixelToDigitalWidthRatio
            }

            if prevMinY != minY {
                minPixelToDigitalHeightRatio = layer.pixelToDigitalHeightRatio
            }
            if prevMaxY != maxY {
                maxPixelToDigitalHeightRatio = layer.pixelToDigitalHeightRatio
            }
        }

        guard var minX, var minY, var maxX, var maxY,
              let minPixelToDigitalWidthRatio, let minPixelToDigitalHeightRatio,
              let maxPixelToDigitalWidthRatio, let maxPixelToDigitalHeightRatio else { return (nil, nil) }

        let pixelSize = CGSize(width: maxX - minX, height: maxY - minY)

        minX /= minPixelToDigitalWidthRatio
        minY /= minPixelToDigitalHeightRatio
        maxX /= maxPixelToDigitalWidthRatio
        maxY /= maxPixelToDigitalHeightRatio

        let layerRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

        return (layerRect, pixelSize)
    }

    func toggleIsActiveStatus(layerModel: LayerModel) {
        if activeLayer == layerModel {
            deactivateLayer()
        } else {
            activeLayer = layerModel
            objectWillChange.send()
        }
    }

    func toggleToMergeStatus(layerModel: LayerModel) {
        if layersToMerge.contains(layerModel) {
            layersToMerge.removeAll { $0.fileName == layerModel.fileName }
        } else {
            layersToMerge.append(layerModel)
        }
    }

    func mergeLayers() async throws {
        guard layersToMerge.count > 1 else { return }

        let (mergedLayerBounds, mergedLayersPixelSize) = calculateBoundsForMergedLayers()

        guard let mergedLayersPixelSize, let mergedLayerBounds else { return }

        let mergedCGImage = try await photoExporterService
            .exportLayersToImage(
                photos: layersToMerge,
                contextPixelSize: mergedLayersPixelSize,
                backgroundColor: UIColor.clear.cgColor,
                offsetFromCenter: CGPoint(x: -mergedLayerBounds.midX *
                    mergedLayersPixelSize.width /
                    mergedLayerBounds.width,
                    y: -mergedLayerBounds.midY *
                        mergedLayersPixelSize.height /
                        mergedLayerBounds.height))

        let mergedLayerFileName = UUID().uuidString + ".PNG"
        try await saveNewCGImageOnDisk(fileName: mergedLayerFileName, cgImage: mergedCGImage)

        let newEntity = PhotoEntity(fileName: mergedLayerFileName, projectEntity: projectModel.imageProjectEntity)
        let mergedLayerModel = LayerModel(photoEntity: newEntity)
        newEntity.photoEntityToImageProjectEntity = projectModel.imageProjectEntity

        mergedLayerModel.position = CGPoint(x: mergedLayerBounds.midX, y: mergedLayerBounds.midY)

        cleanupAfterMerge()

        projectLayers.append(mergedLayerModel)

        showLayerOnScreen(layerModel: mergedLayerModel)
    }

    func addBackgroundToLayer() async throws {
        guard let activeLayer else { return }
        activeLayer.cgImage = originalCGImage

        let layerWithBackground = try await photoExporterService
            .exportLayersToImage(
                photos: [activeLayer],
                contextPixelSize: activeLayer.pixelSize,
                backgroundColor: UIColor.clear.cgColor,
                layersBackgroundColor: currentLayerBackgroundColor.cgColor!,
                isApplyingTransforms: false)

//        try await saveNewCGImageOnDisk(fileName: activeLayer.fileName, cgImage: layerWithBackground)

        activeLayer.cgImage = layerWithBackground
        objectWillChange.send()
    }

    func cleanupAfterMerge() {
        for layerToDelete in layersToMerge {
            layerToDelete.toDelete = true
            layerToDelete.positionZ = nil
        }
        layersToMerge.removeAll()

        currentTool = .none
    }

    func cropLayer(frameRect: CGRect, cropRect: CGRect) async throws {
        guard let activeLayer else { return }

        let widthRatio = CGFloat(activeLayer.cgImage.width) / frameRect.width
        let heightRatio = CGFloat(activeLayer.cgImage.height) / frameRect.height

        let pixelFrameSize = frameRect.size.pixelSize(widthRatio,
                                                      heightRatio)

        let pixelCropSize = cropRect.size.pixelSize(widthRatio,
                                                    heightRatio)

        let pixelOffset = CGSize(width: cropRect.origin.x * widthRatio,
                                 height: cropRect.origin.y * heightRatio)

        let path = currentCropShape.shape.path(in: CGRect(
            origin: .zero,
            size: cropRect.size.pixelSize(widthRatio, heightRatio)))

        let croppedCGImage =
            try await photoExporterService
                .cropLayerToImage(layer: activeLayer,
                                  pixelFrameSize: pixelFrameSize,
                                  pixelCropSize: pixelCropSize,
                                  pixelOffset: pixelOffset,
                                  path: path)

        try await saveNewCGImageOnDisk(fileName: activeLayer.fileName, cgImage: croppedCGImage)

        withAnimation {
            activeLayer.cgImage = croppedCGImage
            activeLayer.size = calculateLayerSize(layerModel: activeLayer)
        }

        objectWillChange.send()
    }

    func deactivateLayer() {
        disablePreviewCGImage()
        if let activeLayer {
            Task {
                try await saveNewCGImageOnDisk(fileName: activeLayer.fileName, cgImage: activeLayer.cgImage)
            }
        }
        activeLayer = nil
    }

    func disablePreviewCGImage() {
        if let originalCGImage, isInNewCGImagePreview {
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
        frame.rect = calculateFrameRect()

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

        deactivateLayer()
        activeLayer = layerModel

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

    func calculateFrameRect(customBounds: CGSize? = nil, isMargined: Bool = true) -> CGRect? {
        guard let projectPixelFrameWidth = projectModel.framePixelWidth,
              let projectPixelFrameHeight = projectModel.framePixelHeight,
              let marginedWorkspaceSize,
              let absoluteWorkspaceSize = workspaceSize
        else { return nil }

        let bounds = customBounds ?? .init(width: projectPixelFrameWidth, height: projectPixelFrameHeight)

        let workspaceSize = isMargined ? marginedWorkspaceSize : absoluteWorkspaceSize

        let validatedProjectPixelFrameWidth =
            max(min(bounds.width, CGFloat(frame.maxPixels)),
                CGFloat(frame.minPixels))

        let validatedProjectPixelFrameHeight =
            max(min(bounds.height, CGFloat(frame.maxPixels)),
                CGFloat(frame.minPixels))

        let aspectRatio = validatedProjectPixelFrameHeight / validatedProjectPixelFrameWidth
        let workspaceAspectRatio = workspaceSize.height / workspaceSize.width

        let frameSize = if aspectRatio < workspaceAspectRatio {
            CGSize(width: workspaceSize.width, height: workspaceSize.width * aspectRatio)
        } else {
            CGSize(width: workspaceSize.height / aspectRatio, height: workspaceSize.height)
        }

        return CGRect(origin: CGPoint(x: -frameSize.width * 0.5, y: -frameSize.height * 0.5),
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

            guard let outputImage = filter.outputImage?.cropped(to: ciImage.extent) else { return nil }

            let context = CIContext()

            let newExtent = ciImage.extent.insetBy(dx: -outputImage.extent.origin.x * 0.5,
                                                   dy: -outputImage.extent.origin.y * 0.5)
            guard let cgImage = context.createCGImage(outputImage, from: newExtent) else { return nil }

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
