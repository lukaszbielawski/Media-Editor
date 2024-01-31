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

    let lowerToolbarHeight: Double
    let padding: Double

    var body: some View {
        ZStack {
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

                    ForEach(vm.projectPhotos) { photo in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: UIImage(cgImage: photo.cgImage))
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
                                        .foregroundStyle(Color(.tint))
                                }
                                .padding(.top, padding * lowerToolbarHeight)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    vm.photoToDelete = photo
                                    isDeleteImageAlertPresented = true
                                }
                        }.onTapGesture {
                            vm.addPhotoLayer(photo: photo)
                        }
                    }
                }
            }
        }.alert("Deleting image", isPresented: $isDeleteImageAlertPresented) {
            Button("Cancel", role: .cancel) {
                isDeleteImageAlertPresented = false
                vm.photoToDelete = nil
            }

            Button("Confirm", role: .destructive) {
                isDeleteImageAlertPresented = false
                guard let photoToDelete = vm.photoToDelete else { return }
                PersistenceController.shared.photoController.delete(for: photoToDelete.fileName)
                vm.projectPhotos.removeAll { $0.fileName == photoToDelete.fileName }
                PersistenceController.shared.saveChanges()
                vm.photoToDelete = nil
            }

        } message: {
            Text("Are you sure you want to remove this image from the project?")
        }
        .padding(.horizontal, padding * lowerToolbarHeight)
    }
}
