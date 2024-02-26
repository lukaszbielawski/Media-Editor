//
//  ImageProjectToolCaseLayersView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 12/02/2024.
//

import SwiftUI

struct ImageProjectToolCaseLayersView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    let filteredArray = vm.projectLayers
                        .filter { $0.positionZ != nil }
                        .sorted { abs($0.positionZ!) > abs($1.positionZ!) }
                    ForEach(filteredArray) { layerModel in

                        let index = filteredArray.firstIndex(of: layerModel)!
                        if let positionZ = layerModel.positionZ {
                            ZStack(alignment: .topTrailing) {
                                Image(decorative: layerModel.cgImage, scale: 1.0)
                                    .centerCropped()
                                    .modifier(ProjectToolTileViewModifier())
                                    .contentShape(Rectangle())
                                VStack(alignment: .trailing) {
                                    Circle()
                                        .fill(Color(.image))
                                        .frame(width: 25, height: 25)
                                        .padding(4.0)
                                        .overlay {
                                            Image(systemName: "eye")
                                                .padding(8)
                                                .symbolVariant(positionZ > 0 ? .fill : .slash.fill)
                                                .foregroundStyle(Color(.tint))
                                        }
                                        .padding(.top, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            layerModel.positionZ = -positionZ
                                            if vm.activeLayer == layerModel,
                                               let positionZ = layerModel.positionZ,
                                               positionZ <= 0
                                            {
                                                vm.activeLayer = nil
                                            }
                                            vm.updateLatestSnapshot()
                                            vm.objectWillChange.send()
                                        }

                                    HStack {
                                        Circle()
                                            .fill(Color(.image))
                                            .frame(width: 25, height: 25)
                                            .padding(4.0)
                                            .overlay {
                                                Image(systemName: "arrow.left")
                                                    .padding(8)
                                                    .foregroundStyle(Color(.tint))
                                                    .transition(.slide)
                                            }
                                            .contentShape(Rectangle())
                                            .gesture(index != 0 ? TapGesture().onEnded {
                                                vm.swapLayersPositionZ(lhs: filteredArray[index - 1],
                                                                       rhs: filteredArray[index])
                                            } : nil)
                                            .opacity(index != 0 ? 1.0 : 0.0)

                                        Spacer()
                                        Circle()
                                            .fill(Color(.image))
                                            .frame(width: 25, height: 25)
                                            .padding(4.0)
                                            .overlay {
                                                Image(systemName: "arrow.right")
                                                    .padding(8)
                                                    .foregroundStyle(Color(.tint))
                                            }
                                            .contentShape(Rectangle())
                                            .gesture(index != filteredArray.count - 1 ? TapGesture().onEnded {
                                                vm.swapLayersPositionZ(lhs: filteredArray[index],
                                                                       rhs: filteredArray[index + 1])
                                            } : nil)
                                            .opacity(index != filteredArray.count - 1 ? 1.0 : 0.0)
                                    }
                                    .padding(.bottom, -vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                                }

                            }.onTapGesture {
                                vm.showLayerOnScreen(layerModel: layerModel)
                            }.animation(.easeInOut(duration: 0.35), value: layerModel.positionZ)
                        }
                    }
                }
            }
    }
}
