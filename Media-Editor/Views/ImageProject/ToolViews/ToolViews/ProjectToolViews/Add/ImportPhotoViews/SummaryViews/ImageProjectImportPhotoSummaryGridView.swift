//
//  ImageProjectImportPhotoSummaryGridView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import SwiftUI

struct ImageProjectImportPhotoSummaryGridView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @Namespace var last

    var totalHeight: Double
    let padding = 0.1

    var tileWidth: Double { totalHeight * (1 - 2 * padding) * 0.50 }

    var body: some View {
        HStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: tileWidth * padding) {
                        ForEach(vm.selectedPhotos, id: \.localIdentifier) { photo in

                            ImageProjectImportPhotoGridTileView(isThumbnail: true, image: photo)
                        }
                        Spacer()
                            .id(last)
                    }
                }
                .onChange(of: vm.selectedPhotos.count) { _ in
                    DispatchQueue.main.async {
                        withAnimation {
                            proxy.scrollTo(last, anchor: .trailing)
                        }
                    }
                }
            }

            Image(systemName: "plus")
                .font(.title)
                .foregroundStyle(Color(.tint))
                .frame(width: tileWidth, height: tileWidth)
                .background {
                    Circle().fill(Color(.image))
                }.onTapGesture {
                    Task {
                        do {
                            try await vm.addAssetsToProject()
                            vm.selectedPhotos.removeAll()
                            vm.tools.isImportPhotoViewShown = false
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding(.vertical, padding * tileWidth)
        }

        .onChange(of: vm.selectedPhotos.count) { _ in
        }
        .frame(height: tileWidth)
        .padding(.horizontal, 2 * padding * tileWidth)
    }
}
