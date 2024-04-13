//
//  AddProjectViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Combine
import CoreData
import Foundation
import Photos
import SwiftUI

@MainActor
final class AddProjectViewModel: ObservableObject {
    @Published var media = [PHAsset]()
    @Published var selectedAssets = [PHAsset]()
    @Published var createdProject: ImageProjectEntity?

    @Published var isPermissionGranted: Bool = true

    private let photoService = PhotoLibraryService()

    private var subscription: AnyCancellable?

    init() {
        setupSubscription()
        requestPermission()
    }

    func requestPermission() {
        Task {
            photoService.requestAuthorization { [unowned self] completion in
                self.isPermissionGranted = completion
            }
        }
    }

    private func setupSubscription() {
        subscription = photoService
            .mediaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] assets in
                media = assets
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

    func toggleMediaSelection(for asset: PHAsset) -> Bool {
        let index = selectedAssets.firstIndex(of: asset)

        if let index {
            selectedAssets.remove(at: index)
        } else {
            selectedAssets.append(asset)
        }
        objectWillChange.send()
        return index == nil
    }

    func runCreateProjectTask() async throws {
        createdProject = try await Task.detached { [unowned self] in
            try await createProject()
        }.value
    }

    func createProject() async throws -> ImageProjectEntity {
        let projectEntity = ImageProjectEntity(id: UUID(), title: "New photo project")
        let projectModel = ImageProjectModel(imageProjectEntity: projectEntity)
        let fileNames = try await photoService.saveAssetsAndGetFileNames(assets: selectedAssets)
        try projectModel.insertPhotosEntityToProject(fileNames: fileNames)
        return projectEntity
    }
}
