//
//  AddProjectViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Combine
import Foundation
import Photos
import SwiftUI

class AddProjectViewModel: ObservableObject {
    @Published var media = [PHAsset]()
    @Published private var photoService = PhotoLibraryService()
    @Published var selectedAssets = Array<PHAsset>()
    @Published var projectType: ProjectType = .none
    
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
            projectType = .none
            return
        }
        let mediaType = selectedAssets.contains { $0.mediaType == .video } ? PHAssetMediaType.video : PHAssetMediaType.image
        projectType = mediaType.toMediaType
    }
}
