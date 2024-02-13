//
//  ImageProjectToolScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolScrollView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var opacity: Double = 1.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ToolType.allCases.filter { $0 != .none }) { tool in
                        Button(action: {
                            vm.currentTool = tool
                        }, label: {
                            ImageProjectToolTileView(title: tool.name,
                                                     iconName: tool.icon)
                        })
                        .opacity(opacity)
                    }
                }
            }
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.5), value: opacity)
            .onChange(of: vm.currentTool) { tool in
                if tool != .none {
                    opacity = 0.0
                } else {
                    opacity = 1
                }
            }
            .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
            .frame(height: vm.plane.lowerToolbarHeight)
            .background(Color(.image))

            if vm.currentTool != .none {
                ImageProjectToolDetailsView()
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
                    .environmentObject(vm)

                ZStack {
                    Circle().fill(Color(.image))

                    Button(action: {
                        DispatchQueue.main.async {
                            vm.currentTool = .none
                        }
                    }, label: {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundStyle(Color(.tint))
                            .contentShape(Rectangle())
                            .font(.title)
                    })
                }

                .frame(width: vm.plane.lowerToolbarHeight * 0.5,
                       height: vm.plane.lowerToolbarHeight * 0.5)

                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
                .offset(
                    x: vm.tools.paddingFactor * vm.plane.lowerToolbarHeight,
                    y: -(1 + 2 * vm.tools.paddingFactor) * vm.plane.lowerToolbarHeight * 0.5)
            }
        }
        
    }
}
