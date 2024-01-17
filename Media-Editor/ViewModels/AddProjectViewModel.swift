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
    @Published var createdProject: ImageProjectEntity? = nil
    @Published var projectType: ProjectType = .unknown
    
    private let photoService = PhotoLibraryService()
    
    private var calculatedProjectType: ProjectType {
        if selectedAssets.isEmpty {
            return .unknown
        }
        let mediaType = selectedAssets.contains { $0.mediaType == .video } ? PHAssetMediaType.video : PHAssetMediaType.image
        return mediaType.toMediaType
    }
    
    private var subscription: AnyCancellable?
    
    init() {
        setupSubscription()
        photoService.requestAuthorization()
    }
    
    private func setupSubscription() {
        subscription = photoService
            .mediaPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] assets in
                media = assets
            }
    }
    
    func fetchPhoto(for asset: PHAsset, desiredSize: CGSize, contentMode: PHImageContentMode = .default) async throws -> UIImage {
        try await photoService.fetchThumbnail(for: asset.localIdentifier, desiredSize: desiredSize, contentMode: contentMode)
    }
    
    func toggleMediaSelection(for asset: PHAsset) -> Bool {
        let index = selectedAssets.firstIndex(of: asset)
            
        if let index {
            selectedAssets.remove(at: index)
        } else {
            selectedAssets.append(asset)
        }
        objectWillChange.send()
        projectType = calculatedProjectType
        return index == nil
    }
    
    func runCreateProjectTask() async throws {
        createdProject = try await Task.detached { [unowned self] in
            try await createProject()
        }.value
    }
    
    func createProject() async throws -> ImageProjectEntity {
        let container = PersistenceController.shared.container
        let isMovie = projectType == ProjectType.movie
        let projectEntity = ImageProjectEntity(id: UUID(), title: "New \(isMovie ? "movie" : "photo") project",
                                          isMovie: isMovie, context: container.viewContext)
            
        try await withThrowingTaskGroup(of: String.self) { [unowned self] group in
            for asset in selectedAssets {
                group.addTask { [unowned self] in
                    let (assetData, fileExtension)
                        = try await photoService.fetchMediaDataAndExtensionFromPhotoLibrary(with: asset.localIdentifier)
                    let savedFileURL = try await photoService.saveToDisk(data: assetData, extension: fileExtension)
                    return savedFileURL.lastPathComponent
                }
            }
            for try await fileName in group {
                let mediaEntity = PhotoEntity(fileName: fileName, projectEntity: projectEntity, context: container.viewContext)
                projectEntity.projectEntityToMediaEntity?.insert(mediaEntity)
            }
              
            print(PersistenceController.shared.projectController.saveChanges())
        }
        
        return projectEntity
    }
}
