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
                                                position: position,
                                                geoSize: geoSize,
                                                planeSize: planeSize,
                                                totalNavBarHeight: totalNavBarHeight,
                                                rotation: $rotation,
                                                scaleX: $scaleX,
                                                scaleY: $scaleY)
                    { editAction in
                        switch editAction {
                        case .delete:
                            print("delete")
                        case .rotateLeft:
                            if rotation != nil {
                                withAnimation {
                                    let leftRadians = abs(rotation!.radians.truncatingRemainder(dividingBy: .pi / 2))
                                    self.rotation! -= Angle(radians: .pi / 2 - leftRadians)
                                }
                                image.photoEntity.rotation = NSNumber(value: rotation!.radians)
                            }

                        case .rotation(let angle):
                            rotation = angle
                            image.photoEntity.rotation = NSNumber(value: rotation!.radians)

                        case .flip:
                            let scaleY = image.photoEntity.scaleY
                            guard let scaleY else { return }
                            let newScale = NSNumber(value: Double(truncating: scaleY) * -1.0)
                            image.photoEntity.scaleY = newScale
                            self.scaleY = Double(truncating: scaleY) * -1.0

                        case .aspectResize(let translation):
                            guard let layerSize else { return }

                            let scale = min(
                                (translation.width + layerSize.width) / layerSize.width,
                                (translation.height + layerSize.height) / layerSize.height
                            ) * min(scaleX!, scaleY!)
                            guard layerSize.width * scale > 30, layerSize.height * scale > 30 else { return }

                            // TODO: nie niwelować istniejących już scale != 1.0

                            self.scaleX! = scale
                            self.scaleY! = scale
                            image.photoEntity.scaleX = NSNumber(value: scaleX!)
                            image.photoEntity.scaleY = NSNumber(value: scaleY!)

                        case .leadingResize:
                            print("leadingResize")
                        case .topResize(let translation):
                            guard let layerSize else { return }

                            let scale = ((-translation.height + layerSize.height) / layerSize.height) * scaleY!
                            print("scale", scale)
                            guard layerSize.height * scale > 30 else { return }

                            print(translation)

                            // TODO: resize tylko w jedną stronę

                            self.scaleY! = scale
                            image.photoEntity.scaleY = NSNumber(value: scaleY!)

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
                    if image.photoEntity.positionX == 0.0 {
                        position = globalPosition
                        rotation = .zero
                        scaleX = 1.0
                        scaleY = 1.0
                    } else {
                        position = globalPosition + CGPoint(x: image.photoEntity.positionX as! Double,
                                                            y: image.photoEntity.positionY as! Double)
                        rotation = Angle(radians: image.photoEntity.rotation as! Double)
                        scaleX = image.photoEntity.scaleX as? Double
                        scaleY = image.photoEntity.scaleY as? Double
                    }
                    layerSize = vm.calculateLayerSize(photo: image,
                                                      geoSize: geoSize,
                                                      framePaddingFactor: framePaddingFactor,
                                                      totalLowerToolbarHeight: totalLowerToolbarHeight)
                }
                .rotationEffect(rotation ?? .zero)
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
                        DragGesture(coordinateSpace: .local)
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
                            PersistenceController.shared.photoController.saveChanges()
                        }
                        : nil
                )
        }
    }
}
