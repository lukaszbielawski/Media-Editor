//
//  ImageProjectImportPhotoGridTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import Photos
import SwiftUI

struct ImageProjectImportPhotoGridTileView: View {
    @State var thumbnail: UIImage?
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var isSelected: Bool = false

    var isThumbnail: Bool = false

    @State var image: PHAsset
    var body: some View {
        ZStack {
            ZStack {
                Group {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .centerCropped()
                    } else {
                        Color(.primary)
                    }
                }.aspectRatio(1.0, contentMode: .fill)
                    .cornerRadius(4.0)

            }.overlay {
                if isSelected {
                    ZStack(alignment: .topLeading) {
                        Color(.primary)
                            .opacity(isSelected ? 0.7 : 0)
                            .aspectRatio(1.0, contentMode: .fill)
                            .cornerRadius(4.0)
                        Circle()
                            .fill(Color(.primary))
                            .frame(width: 25, height: 25)
                            .padding(4.0)
                            .overlay {
                                Text("\((vm.selectedPhotos.firstIndex(of: image) ?? 0) + 1)")
                            }
                    }
                }
            }
            .onChange(of: vm.selectedPhotos.firstIndex(of: image)) { _ in
                if !vm.selectedPhotos.contains(where: { $0.localIdentifier == image.localIdentifier }) {
                    isSelected = false
                }
            }
        }.onAppear {
            if !isThumbnail {
                if vm.selectedPhotos.contains(where: { $0.localIdentifier == image.localIdentifier }) {
                    isSelected = true
                }
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 4.0))
        .onTapGesture {
            HapticService.shared.play(.light)
            isSelected = vm.toggleImageSelection(for: image)
        }
        .task {
            thumbnail = try? await vm.fetchPhoto(for: image, desiredSize:
                .init(width: UIScreen.main.nativeBounds.width *
                    (UIDevice.current.userInterfaceIdiom == .phone ? 0.33 : 0.2),
                    height: UIScreen.main.nativeBounds.width *
                        (UIDevice.current.userInterfaceIdiom == .phone ? 0.33 : 0.2)))

        }.onDisappear {
            thumbnail = nil
        }
    }
}
