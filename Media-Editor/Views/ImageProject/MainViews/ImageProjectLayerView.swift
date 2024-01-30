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
                .modifier(EditFrameToolModifier(width: layerSize?.width ?? 0,
                                                height: layerSize?.height ?? 0,
                                                isActive: vm.activeLayerPhoto == image,
                                                geoSize: geoSize,
                                                planeSize: planeSize,
                                                totalNavBarHeight: totalNavBarHeight,
                                                rotation: $rotation, position: $position,
                                                scaleX: $scaleX,
                                                scaleY: $scaleY)
                    { editAction in
                        switch editAction {
                        case .delete:
                            print("delete")
                        case .rotateLeft:
                            if rotation != nil {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    self.rotation = Angle(radians:
                                        ceil(self.rotation!.radians / (.pi * 0.495)) * (.pi * 0.5) - 0.5 * .pi)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    image.photoEntity.rotation = NSNumber(value: rotation!.radians)
                                    print(image.photoEntity.rotation)
                                    _ = PersistenceController.shared.photoController.saveChanges()
                                }
                            }

                        case .rotation(let angle):
                            rotation = angle
                            image.photoEntity.rotation = NSNumber(value: rotation!.radians)

                        case .flip:
                            let rotation = rotation?.normalizedRotation ?? 0.0
                            print(rotation, "norm")
                            if ((.pi * 0.25)...(.pi * 0.75)).contains(rotation) ||
                                ((.pi * 1.25)...(.pi * 1.75)).contains(rotation)
                            {
                                let scaleY = image.photoEntity.scaleY
                                guard let scaleY else { return }

                                let newScale = NSNumber(value: Double(truncating: scaleY) * -1.0)
                                image.photoEntity.scaleY = newScale
                                self.scaleY = Double(truncating: scaleY) * -1.0

                            } else {
                                let scaleX = image.photoEntity.scaleX
                                guard let scaleX else { return }

                                let newScale = NSNumber(value: Double(truncating: scaleX) * -1.0)
                                image.photoEntity.scaleX = newScale
                                self.scaleX = Double(truncating: scaleX) * -1.0
                            }
                            _ = PersistenceController.shared.photoController.saveChanges()

                        case .aspectResize(let translation):
                            guard let layerSize else { return }

                            let scale = min(
                                (translation.width + layerSize.width) / layerSize.width,
                                (translation.height + layerSize.height) / layerSize.height
                            ) * min(scaleX!, scaleY!)
                            guard layerSize.width * scale > 30, layerSize.height * scale > 30 else { return }

                            DispatchQueue.main.async {
                                scaleX = scale
                                scaleY = scale
                                image.photoEntity.scaleX = NSNumber(value: scaleX!)
                                image.photoEntity.scaleY = NSNumber(value: scaleY!)
                            }

                        case .leadingResize:
                            print("leadingResize")
                        case .topResize(let heightDiff):
                            guard let layerSize else { return }

                            let scale = ((-heightDiff + layerSize.height) / layerSize.height) * scaleY!
                            print("scale", scale)
                            guard layerSize.height * scale > 30 else { return }

                            






//
//                            DispatchQueue.main.async {
//                                scaleY = scale
//                                guard let position else { return }
//                                image.photoEntity.scaleY = NSNumber(value: scaleY!)
//                                image.photoEntity.positionX = (position.x - globalPosition.x) as NSNumber
//                                image.photoEntity.positionY = (position.y - globalPosition.y) as NSNumber
//                            }

                            print("x", scaleX!, "y", scaleY!)
                        case .trailingResize:
                            print("trailingResize")
                        case .bottomResize:
                            print("bottomResize")
                        case .save:
                            _ = PersistenceController.shared.photoController.saveChanges()
                        }
                    })

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

                            print("drag position", position)

                            guard let position else { return }
                            image.photoEntity.positionX = (position.x - globalPosition.x) as NSNumber
                            image.photoEntity.positionY = (position.y - globalPosition.y) as NSNumber
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
