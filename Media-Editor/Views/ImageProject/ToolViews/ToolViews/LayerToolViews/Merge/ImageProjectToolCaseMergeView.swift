//
//  ImageProjectToolCaseMergeView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/03/2024.
//

import SwiftUI

struct ImageProjectToolCaseMergeView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                let filteredArray = vm.projectLayers
                    .filter { $0.positionZ != nil }
                    .filter { $0.positionZ! > 0 }
                    .sorted { $0.positionZ! > $1.positionZ! }
                ForEach(filteredArray) { layerModel in
                    ZStack(alignment: .topTrailing) {
                        Image(decorative: layerModel.cgImage, scale: 1.0)
                            .centerCropped()
                            .contentShape(Rectangle())
                            .overlay {
                                if vm.layersToMerge.contains(layerModel) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius:
                                            vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                                            .fill(Color(.accent))
                                        RoundedRectangle(cornerRadius:
                                            vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                                            .fill(Color.white)
                                            .padding(2.0)
                                            .blendMode(.destinationOut)
                                    }
                                    .compositingGroup()
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                                }
                            }
                            .modifier(ProjectToolTileViewModifier())
                    }

                    .onTapGesture {
                        vm.toggleToMergeStatus(layerModel: layerModel)
                    }.animation(.easeInOut(duration: 0.35), value: layerModel.positionZ)
                }
            }
        }
    }
}
