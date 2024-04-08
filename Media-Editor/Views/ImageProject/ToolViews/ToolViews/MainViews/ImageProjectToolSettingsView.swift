//
//  ImageProjectToolSettingsView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/03/2024.
//

import SwiftUI

struct ImageProjectToolSettingsView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    var body: some View {
        HStack(spacing: 0) {
            switch vm.currentTool {
            case let layerTool as LayerToolType:
                ImageProjectToolFloatingButtonView(
                    systemName: vm.tools.leftFloatingButtonIcon,
                    buttonType: .left)
                    .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                if vm.currentFilter != .none {
                    ImageProjectToolFilterFloatingSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                } else if layerTool == .crop {
                    ImageProjectViewFloatingCropSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                } else if layerTool == .background {
                    Spacer()
                    ImageProjectFloatingBackgroundSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5,
                        backgroundColor: $vm.currentLayerBackgroundColor,
                        colorPickerType: .layerBackground)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                }

            case let projectTool as ProjectToolType:
                ImageProjectToolFloatingButtonView(
                    systemName: vm.tools.leftFloatingButtonIcon,
                    buttonType: .left)
                    .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)

                switch projectTool {
                case .merge:
                    Spacer()
                    ImageProjectFloatingMergeSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5,
                        backgroundColor: $vm.projectModel.backgroundColor)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                        .frame(maxWidth: 300, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                case .text:
                    Spacer()
                    ImageProjectToolTextFloatingTextFieldView(textFieldHeight: vm.plane.lowerToolbarHeight * 0.5)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                        .onAppear {
                            vm.tools.rightFloatingButtonIcon = "checkmark"
                        }
                case .background:
                    Spacer()
                    ImageProjectFloatingBackgroundSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5,
                        backgroundColor: $vm.projectModel.backgroundColor)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                default:
                    EmptyView()
                }
            case let layerSingleTool as LayerSingleActionToolType:
                EmptyView()
            default:
                EmptyView()
            }
        }
        .offset(
            y: -(1 + 2 * vm.tools.paddingFactor) * vm.plane.lowerToolbarHeight * 0.5)
        .padding(.trailing, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
        .onReceive(vm.floatingButtonClickedSubject) { [weak vm] functionType in
            guard let vm else { return }
            if functionType == .back {
                vm.currentTool = nil
            }
        }
    }
}
