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
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(vm.libraryPhotos, id: \.localIdentifier) { photo in
                    ZStack {
                        ImageProjectImportPhotoGridTileView(image: photo)
                    }
                }
            }
        }
        .padding(4)
    }
}
