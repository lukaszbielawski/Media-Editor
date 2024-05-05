//
//  ImageProjectToolCaseDrawView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct ImageProjectToolCaseDrawView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ImageProjectToolTileView(title: "Color", iconName: "paintpalette.fill")
                    .onTapGesture {
                        vm.currentColorPickerType = .pencilColor
                    }
                    .overlay {
                        if vm.currentDrawing.currentPencilType == .eraser {
                            Color.white
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
                ForEach(PencilType.allCases, id: \.self) { pencilType in
                    ImageProjectToolTileView(
                        title: pencilType.name,
                        systemName: pencilType.icon)
                        .centerCropped()
                        .overlay {
                            if vm.currentDrawing.currentPencilType == pencilType {
                                Color.accent
                                    .modifier(ProjectToolTileSelectedModifier(paddingFactor: vm.tools.paddingFactor, lowerToolbarHeight: vm.plane.lowerToolbarHeight))
                            }
                        }
                        .modifier(ProjectToolTileViewModifier())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.currentDrawing.currentPencilType = pencilType
                        }
                }
            }
        }.onAppear {
            vm.turnOnDrawingRevertModel()
        }
    }
}
