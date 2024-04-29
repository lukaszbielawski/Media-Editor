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
                    if let layerModelImage = layerModel.cgImage {
                        ZStack(alignment: .topTrailing) {
                            Image(decorative: layerModelImage, scale: 1.0)
                                .centerCropped()
                                .contentShape(Rectangle())
                                .overlay {
                                    if vm.layersToMerge.contains(layerModel) {
                                        Color.accent
                                            .modifier(ProjectToolTileSelectedModifier(paddingFactor: vm.tools.paddingFactor, lowerToolbarHeight: vm.plane.lowerToolbarHeight))
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
}
