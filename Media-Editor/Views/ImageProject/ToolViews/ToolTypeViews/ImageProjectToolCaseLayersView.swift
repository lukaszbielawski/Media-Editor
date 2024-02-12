//
//  ImageProjectToolCaseLayersView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 12/02/2024.
//

import SwiftUI

struct ImageProjectToolCaseLayersView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var isDeleteImageAlertPresented: Bool = false

    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(vm.projectLayers.filter { $0.positionZ != nil }.sorted { abs($0.positionZ!) > abs($1.positionZ!) }) { layerModel in
                        let filteredArray = vm.projectLayers.filter { $0.positionZ != nil }.sorted { abs($0.positionZ!) > abs($1.positionZ!) }
                        let index = filteredArray.firstIndex(of: layerModel)!
                        if let positionZ = layerModel.positionZ {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: UIImage(cgImage: layerModel.cgImage))
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
                                                vm.swapLayersPositionZ(lhs: filteredArray[index - 1], rhs: filteredArray[index])
                                            } : nil)

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
                                                vm.swapLayersPositionZ(lhs: filteredArray[index], rhs: filteredArray[index + 1])
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
        .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
