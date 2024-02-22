//
//  ImageProjectToolScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolScrollView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if vm.activeLayer == nil {
                        ForEach(ProjectToolType.allCases) { tool in
                            Button(action: {
                                vm.currentTool = tool
                            }, label: {
                                ImageProjectToolTileView(title: tool.name,
                                                         iconName: tool.icon)

                            })
                        }
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                    } else {
                        ForEach(LayerToolType.allCases) { tool in
                            Button(action: {
                                vm.currentTool = tool
                            }, label: {
                                ImageProjectToolTileView(title: tool.name,
                                                         iconName: tool.icon)

                            })
                        }
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                    }
                }
            }
            .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
            .frame(height: vm.plane.lowerToolbarHeight)
            .background(Color(.image))

            if vm.currentTool != nil {
                ImageProjectToolDetailsView()
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                    .zIndex(Double(Int.max - 5))
                    .environmentObject(vm)
                ZStack {
                    Circle().fill(Color(.image))

                    Button(action: {
                        DispatchQueue.main.async {
                            vm.tools.leftFloatingButtonAction?()
                        }
                    }, label: {
                        Image(systemName: vm.tools.leftFloatingButtonIcon)
                            .foregroundStyle(Color(.tint))
                            .contentShape(Rectangle())
                            .font(.title)
                    })
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                .frame(width: vm.plane.lowerToolbarHeight * 0.5,
                       height: vm.plane.lowerToolbarHeight * 0.5)
                .offset(
                    x: vm.tools.paddingFactor * vm.plane.lowerToolbarHeight,
                    y: -(1 + 2 * vm.tools.paddingFactor) * vm.plane.lowerToolbarHeight * 0.5)
            }
        }.onAppear {
            vm.tools.leftFloatingButtonAction = { vm.currentTool = .none }
        }
    }
}
