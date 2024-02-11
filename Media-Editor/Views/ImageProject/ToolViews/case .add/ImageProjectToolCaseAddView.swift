//
//  ImageProjectToolCaseAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import SwiftUI

struct ImageProjectToolCaseAddView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var isDeleteImageAlertPresented: Bool = false

    let padding: Double

    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ImageProjectToolTileView(iconName: "plus",
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

                    ForEach(vm.projectLayers) { layerModel in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: UIImage(cgImage: layerModel.cgImage))
                                .centerCropped()
                                .modifier(ProjectToolTileViewModifier(
                                    padding: padding))
                                .contentShape(Rectangle())
                            Circle()
                                .fill(Color(.image))
                                .frame(width: 25, height: 25)
                                .padding(4.0)
                                .overlay {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color(.tint))
                                }
                                .padding(.top, padding * vm.plane.lowerToolbarHeight)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    vm.layerToDelete = layerModel
                                    isDeleteImageAlertPresented = true
                                }
                        }.onTapGesture {
                            vm.showLayerOnScreen(layerModel: layerModel)
                        }
                    }
                }
            }
        }.alert("Deleting image", isPresented: $isDeleteImageAlertPresented) {
            Button("Cancel", role: .cancel) {
                isDeleteImageAlertPresented = false
                vm.layerToDelete = nil
            }

            Button("Confirm", role: .destructive) {
                isDeleteImageAlertPresented = false
                guard let photoToDelete = vm.layerToDelete else { return }
                PersistenceController.shared.photoController.delete(for: photoToDelete.fileName)
                vm.projectLayers.removeAll { $0.fileName == photoToDelete.fileName }
                PersistenceController.shared.saveChanges()
                vm.layerToDelete = nil
            }

        } message: {
            Text("Are you sure you want to remove this image from the project?")
        }
        .padding(.horizontal, padding * vm.plane.lowerToolbarHeight)
    }
}
