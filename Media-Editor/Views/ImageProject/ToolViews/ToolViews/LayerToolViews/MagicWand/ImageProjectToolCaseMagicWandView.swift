//
//  ImageProjectToolCaseMagicWandView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/05/2024.
//

import SwiftUI

struct ImageProjectToolCaseMagicWandView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ImageProjectToolTileView(title: "Color", iconName: "paintpalette.fill")
                    .onTapGesture {
                        vm.currentColorPickerType = .bucketColorPicker
                    }
                    .overlay {
                        if vm.magicWandModel.magicWandType == .magicWand {
                            Color.tint
                                .opacity(0.4)
                                .overlay {
                                    Image(systemName: "hand.raised.fill")
                                        .resizable()
                                        .foregroundStyle(Color.accentColor)
                                        .scaledToFit()
                                        .padding()
                                        .padding(.bottom)
                                }
                                .centerCropped()
                                .modifier(ProjectToolTileViewModifier())
                                .transition(.normalOpacityTransition)
                        }
                    }
                ForEach(MagicWandType.allCases, id: \.self) { magicWandType in
                    ImageProjectToolTileView(
                        title: magicWandType.name,
                        iconName: magicWandType.iconName)
                        .centerCropped()
                        .overlay {
                            if vm.magicWandModel.magicWandType == magicWandType {
                                Color.accent
                                    .modifier(ProjectToolTileSelectedModifier(paddingFactor: vm.tools.paddingFactor, lowerToolbarHeight: vm.plane.lowerToolbarHeight))
                            }
                        }
                        .modifier(ProjectToolTileViewModifier())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.magicWandModel.magicWandType = magicWandType
                        }
                }
            }
        }
        .onDisappear {
            vm.disposeRevertModel(revertModelType: .magicWand)
        }
    }
}
