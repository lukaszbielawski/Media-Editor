//
//  ImageProjectToolsScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolsScrollView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var areToolDetailsPresented: Bool = false

    let lowerToolbarHeight: CGFloat
    let padding: Double = 0.1

    @State var opacity: Double = 1.0

    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                ForEach(ToolType.allCases.filter { $0 != .none }) { tool in
                    ImageProjectToolTileView(title: tool.name,
                                             systemName: tool.icon,
                                             lowerToolbarHeight: lowerToolbarHeight,
                                             padding: padding)
                        .onTapGesture {
                            vm.currentTool = tool
                        }
                        .opacity(opacity)
                }
            }
            .onChange(of: vm.currentTool) { tool in
                if tool != .none {
                    opacity = 0.0
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.375) {
                        withAnimation(.easeIn(duration: 0.375)) {
                            opacity = 1
                        }
                    }
                }
            }
            .padding(.horizontal, padding * lowerToolbarHeight)
            .frame(height: lowerToolbarHeight)
            .background(Color(.accent))

            ImageProjectToolDetailsView(lowerToolbarHeight:
                lowerToolbarHeight, padding: padding)
                .environmentObject(vm)
                .gesture(DragGesture().onEnded { value in
                    if value.translation.height > 50 {
                        vm.currentTool = .none
                    }
                })
        }
    }
}
