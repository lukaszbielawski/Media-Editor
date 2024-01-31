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
    @State var rotation: Angle?

    @GestureState private var lastPosition: CGPoint?

    @Binding var geoSize: CGSize?
    @Binding var planeSize: CGSize?
    @Binding var totalLowerToolbarHeight: Double?
    @Binding var totalNavBarHeight: Double?

    @State var image: PhotoModel
    @State var scaleX: Double?
    @State var scaleY: Double?

    let framePaddingFactor: Double

    var globalPosition: CGPoint { CGPoint(x: planeSize!.width / 2, y: planeSize!.height / 2) }

    var body: some View {
        if let geoSize, let planeSize, let totalLowerToolbarHeight, image.photoEntity.positionX != nil {
            Image(decorative: image.cgImage, scale: 1.0, orientation: .up)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: layerSize?.width ?? 0, height: layerSize?.height ?? 0)
                .modifier(EditFrameToolModifier(
                    image: $image,
                    rotation: $rotation,
                    position: $position,
                    scaleX: $scaleX,
                    scaleY: $scaleY,
                    isActive: vm.activeLayerPhoto == image,
                    geoSize: geoSize,
                    planeSize: planeSize,
                    layerSize: layerSize,
                    totalNavBarHeight: totalNavBarHeight
                ))
                .onAppear {
                    position = globalPosition +
                        CGPoint(x: image.photoEntity.positionX as? Double ?? 0.0,
                                y: image.photoEntity.positionY as? Double ?? 0.0)
                    rotation = Angle(radians: image.photoEntity.rotation as? Double ?? .zero)
                    print("init rotation", rotation)
                    scaleX = image.photoEntity.scaleX as? Double ?? 1.0
                    scaleY = image.photoEntity.scaleY as? Double ?? 1.0
                    layerSize = vm.calculateLayerSize(photo: image,
                                                      geoSize: geoSize,
                                                      framePaddingFactor: framePaddingFactor,
                                                      totalLowerToolbarHeight: totalLowerToolbarHeight)
                }
                .rotationEffect(rotation ?? .zero)
                .position(position ?? CGPoint())
                .offset()
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
                        }
                        .updating($lastPosition) { _, startPosition, _ in
                            startPosition = startPosition ?? position
                        }.onEnded { _ in
                            PersistenceController.shared.saveChanges()
                        }
                        : nil
                )
        }
    }
}
