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
//                media = fetchResult
            }
    }
    
    func fetchPhoto(for asset: PHAsset, desiredSize: CGSize, contentMode: PHImageContentMode = .default) async throws -> UIImage {
        try await photoService.fetchThumbnail(for: asset.localIdentifier, desiredSize: desiredSize, contentMode: contentMode)
    }
}
