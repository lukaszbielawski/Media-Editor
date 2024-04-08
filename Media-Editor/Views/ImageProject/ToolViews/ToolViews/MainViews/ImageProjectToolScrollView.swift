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
                    } else {
                        Group {
                            if let currentTool = vm.currentTool as? LayerToolType,
                               currentTool == .editText {
                                Button(action: {
                                    vm.currentTool = LayerToolType.editText
                                }, label: {
                                    ImageProjectToolTileView(title: currentTool.name,
                                                             iconName: currentTool.icon)
                                })
                            }
                            ForEach(LayerToolType.allCases) { tool in
                                Button(action: {
                                    vm.currentTool = tool
                                }, label: {
                                    ImageProjectToolTileView(title: tool.name,
                                                             iconName: tool.icon)

                                })
                            }
                            ForEach(LayerSingleActionToolType.allCases) { tool in
                                Button(action: {
                                    vm.performToolActionSubject.send(tool)
                                }, label: {
                                    ImageProjectToolTileView(title: tool.name,
                                                             iconName: tool.icon)
                                })
                            }
                        }
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                    }
                }
            }
            .onReceive(vm.performToolActionSubject) { [unowned vm] tool in
                if let tool = tool as? LayerSingleActionToolType {
                    if tool == .copy {
                        Task {
                            await vm.copyAndAppend()
                        }
                    }
                }
            }
            .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
            .frame(height: vm.plane.lowerToolbarHeight)
            .background(Color(.image))
        }
    }
}
