//
//  ImageProjectImportPhotoView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import SwiftUI

struct ImageProjectImportPhotoGridView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 4),
              count: UIDevice.current.userInterfaceIdiom == .phone ? 3 : 5)

    var body: some View {
        VStack {
            if vm.isPermissionGranted {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(vm.libraryPhotos, id: \.localIdentifier) { photo in
                        ZStack {
                            ImageProjectImportPhotoGridTileView(image: photo)
                        }
                    }
                }
            } else {
                Text("Could not load assets from photo library")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding(.vertical)
                Text("Please allow access to Photo Library in Settings to continue")
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                    .font(.callout)
            }
        }
        .padding(4)
    }
}
