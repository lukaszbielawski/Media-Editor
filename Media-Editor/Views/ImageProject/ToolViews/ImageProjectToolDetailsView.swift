//
//  ImageProjectToolDetailsView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolDetailsView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    let lowerToolbarHeight: Double
    let padding: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.image)
                .frame(height: lowerToolbarHeight)
            switch vm.currentTool {
            case .add:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ImageProjectToolTileView(iconName: "plus",
                                                 lowerToolbarHeight: lowerToolbarHeight,
                                                 padding: padding)
                            .onTapGesture {
                                vm.setupAddAssetsToProject()
                                vm.isImportPhotoViewShown = true
                            }
                            .contentShape(Rectangle())
                            .sheet(isPresented: $vm.isImportPhotoViewShown) {
                                ImageProjectImportPhotoView()
                                    .onDisappear {
                                        vm.selectedPhotos.removeAll()
                                    }
                            }

                        ForEach(vm.projectPhotos) { item in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: UIImage(cgImage: item.cgImage))
                                    .centerCropped()
                                    .modifier(ProjectToolTileViewModifier(
                                        lowerToolbarHeight: lowerToolbarHeight,
                                        padding: padding))
                                    .contentShape(Rectangle())
                                Circle()
                                    .fill(Color(.image))
                                    .frame(width: 25, height: 25)
                                    .padding(4.0)
                                    .overlay {
                                       Image(systemName: "trash")
                                            .allowsHitTesting(false)
                                    }
                                    .padding(.top, padding * lowerToolbarHeight)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        print("delete")
                                    }
                            }
                        }

                    }

                }
                .padding(.horizontal, padding * lowerToolbarHeight)
            default:
                EmptyView()
            }
        }
    }
}
