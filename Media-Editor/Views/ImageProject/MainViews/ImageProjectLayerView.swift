//
//  ImageProjectLayerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectLayerView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var position: CGPoint?
    @State var layerSize: CGSize?

    @GestureState private var lastPosition: CGPoint?

    @Binding var geoSize: CGSize?
    @Binding var planeSize: CGSize?
    @Binding var totalLowerToolbarHeight: Double?

    @State var image: PhotoModel
    let framePaddingFactor: Double

    var globalPosition: CGPoint { CGPoint(x: planeSize!.width / 2, y: planeSize!.height / 2) }

    var body: some View {
        if let geoSize, let planeSize, let totalLowerToolbarHeight {
            ZStack {
                Image(decorative: image.cgImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: layerSize?.width ?? 0, height: layerSize?.height ?? 0)
                    .modifier(
                        EditFrameToolModifier(width: layerSize?.width ?? 0, height: layerSize?.height ?? 0))

            }

            .onAppear {
                if image.photoEntity.positionX == 0.0 {
                    position = globalPosition
                } else {
                    position = globalPosition + CGPoint(x: image.photoEntity.positionX as! Double, y: image.photoEntity.positionY as! Double)
                }

                layerSize = vm.calculateLayerSize(photo: image,
                                                  geoSize: geoSize,
                                                  framePaddingFactor: framePaddingFactor,
                                                  totalLowerToolbarHeight: totalLowerToolbarHeight)
            }
            .position(position ?? CGPoint())
            .onTapGesture {
                if vm.activeLayerPhoto == image {
                    vm.activeLayerPhoto = nil
                } else {
                    vm.activeLayerPhoto = image
                }
            }
            .gesture(
                vm.activeLayerPhoto == image ?
                    DragGesture()
                    .onChanged { value in

                        var newPosition = lastPosition ?? position ?? CGPoint()
                        newPosition.x += value.translation.width
                        newPosition.y += value.translation.height

                        position = newPosition
                        guard let position else { return }
                        image.photoEntity.positionX = (position.x - globalPosition.x) as NSNumber
                        image.photoEntity.positionY = (position.y - globalPosition.y) as NSNumber
                        print(image.photoEntity.positionX, image.photoEntity.positionY)
                    }
                    .updating($lastPosition) { _, startPosition, _ in
                        startPosition = startPosition ?? position
                    }.onEnded { _ in
                        PersistenceController.shared.photoController.saveChanges()
                    }
                    : nil
            )
        }
    }
}
