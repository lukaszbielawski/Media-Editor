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
class AddProjectViewModel: ObservableObject {
    @Published var media = [PHAsset]()
    @Published private var photoService = PhotoLibraryService()
    @Published var selectedAssets = [PHAsset]()
    @Published var projectType: ProjectType = .unknown
    
    @Published var createdProject: ProjectEntity? = nil
    
    private var subscription: AnyCancellable?
    
    init() {
        setupSubscription()
        photoService.requestAuthorization()
    }
    
    private func setupSubscription() {
        let mediaPublisher = photoService.getMediaPublisher()
        subscription = mediaPublisher
            .sink { [unowned self] fetchResult in
                media = (0 ..< fetchResult.count).map { fetchResult.object(at: $0) }
            }
    }
    
    func fetchPhoto(for asset: PHAsset, desiredSize: CGSize, contentMode: PHImageContentMode = .default) async throws -> UIImage {
        try await photoService.fetchThumbnail(for: asset.localIdentifier, desiredSize: desiredSize, contentMode: contentMode)
    }
    
    func toggleMediaSelection(for asset: PHAsset) -> Bool {
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
            objectWillChange.send()
            recalculateProjectType()
            return false
        } else {
            selectedAssets.append(asset)
            objectWillChange.send()
            recalculateProjectType()
            return true
        }
    }
    
    private func recalculateProjectType() {
        if selectedAssets.isEmpty {
            projectType = .unknown
            return
        }
        let mediaType = selectedAssets.contains { $0.mediaType == .video } || selectedAssets.count > 1 ? PHAssetMediaType.video : PHAssetMediaType.image
        projectType = mediaType.toMediaType
    }
    
    func runCreateProjectTask() async throws {
        createdProject = try await Task.detached { [unowned self] in
            try await createProject()
        }.value
    }
    
    func createProject() async throws -> ProjectEntity {
        let container = PersistenceController.shared.container
        let isMovie = projectType == ProjectType.movie
        let projectEntity = ProjectEntity(id: UUID(), title: "New \(isMovie ? "movie" : "photo") project",
                                          lastEditDate: Date.now, isMovie: isMovie, context: container.viewContext)
            
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
                let mediaEntity = MediaEntity(fileName: fileName, projectEntity: projectEntity, context: container.viewContext)
                projectEntity.projectEntityToMediaEntity?.insert(mediaEntity)
            }
              
            print(PersistenceController.shared.projectController.saveChanges())
        }
        
        return projectEntity
    }
}
