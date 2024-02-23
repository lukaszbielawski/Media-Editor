//
//  ImageProjectToolView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import SwiftUI

struct ImageProjectToolView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            ImageProjectToolScrollView()
            if let currentTool = vm.currentTool {
                ImageProjectToolDetailsView()
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                    .zIndex(Double(Int.max - 5))
                    .environmentObject(vm)
                HStack(spacing: 0) {
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.leftFloatingButtonIcon,
                        action: vm.tools.leftFloatingButtonAction)
                    .padding(.trailing, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)

                    if let currentTool = currentTool as? LayerToolType, currentTool == .filters {
                        ImageProjectViewFloatingSliderView(sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                            .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                            .padding(.trailing, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                        Spacer()
                        ImageProjectToolFloatingButtonView(
                            systemName: vm.tools.rightFloatingButtonIcon,
                            action: vm.tools.rightFloatingButtonAction)
                
                    }

                }.offset(
                    y: -(1 + 2 * vm.tools.paddingFactor) * vm.plane.lowerToolbarHeight * 0.5)
                    .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))

                
            }
        }
        .onAppear {
            vm.tools.leftFloatingButtonAction = { vm.currentTool = nil }
        }
    }
}
