//
//  ImageProjectToolFlipAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import SwiftUI

struct ImageProjectToolCaseFlipView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
            HStack {
                ImageProjectToolTileView(iconName: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill")
                    .onTapGesture {
                        guard let layerModel = vm.activeLayer,
                              let rotation = layerModel.rotation else { return }
                        withAnimation {
                            if ((.pi * 0.25)...(.pi * 0.75)).contains(rotation.normalizedRotationRadians) ||
                                ((.pi * 1.25)...(.pi * 1.75)).contains(rotation.normalizedRotationRadians)
                            {
                                layerModel.scaleY? *= -1.0

                            } else {
                                layerModel.scaleX? *= -1.0
                            }
                        }

                        vm.updateLatestSnapshot()
                    }
                    .contentShape(Rectangle())
                ImageProjectToolTileView(iconName: "arrow.up.and.down.righttriangle.up.righttriangle.down.fill")
                    .onTapGesture {
                        guard let layerModel = vm.activeLayer,
                              let rotation = layerModel.rotation else { return }
                        withAnimation {
                            if ((.pi * 0.25)...(.pi * 0.75)).contains(rotation.normalizedRotationRadians) ||
                                ((.pi * 1.25)...(.pi * 1.75)).contains(rotation.normalizedRotationRadians)
                            {
                                layerModel.scaleX? *= -1.0

                            } else {
                                layerModel.scaleY? *= -1.0
                            }
                        }

                        vm.updateLatestSnapshot()
                    }
                    .contentShape(Rectangle())
                Spacer()
            }
    }
}
