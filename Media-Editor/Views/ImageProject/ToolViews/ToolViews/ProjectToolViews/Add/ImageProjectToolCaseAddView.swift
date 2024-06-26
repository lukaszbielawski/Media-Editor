//
//  ImageProjectToolCaseAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import SwiftUI

struct ImageProjectToolCaseAddView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ImageProjectToolTileView(iconName: "plus")
                    .onTapGesture {
                        DispatchQueue.main.async {
                            vm.setupAddAssetsToProject()
                            vm.tools.isImportPhotoViewShown = true
                        }
                    }
                    .contentShape(Rectangle())
                    .sheet(isPresented: $vm.tools.isImportPhotoViewShown) {
                        ImageProjectImportPhotoView()
                            .background {
                                Image("MenuBackground")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .ignoresSafeArea()
                            }
                            .onDisappear {
                                vm.selectedPhotos.removeAll()
                            }
                    }
                ForEach(vm.projectLayers.filter { !($0.toDelete ?? false) }) { layerModel in
                    if let layerImage = layerModel.cgImage {
                        ZStack(alignment: .topTrailing) {
                            Image(decorative: layerImage, scale: 1.0)
                                .centerCropped()
                                .modifier(ProjectToolTileViewModifier())
                                .contentShape(Rectangle())
                            Circle()
                                .fill(Color(.image))
                                .frame(width: 25, height: 25)
                                .padding(4.0)
                                .overlay {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color(.tint))
                                }
                                .padding(.top, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    vm.layerToDelete = layerModel
                                    vm.tools.isDeleteImageAlertPresented = true
                                }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.showLayerOnScreen(layerModel: layerModel)
                        }
                    }
                }
            }
        }
    }
}
