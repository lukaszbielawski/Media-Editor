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
            if !(vm.activeLayer == nil && vm.currentTool == nil) {
                ImageProjectToolFloatingButtonView(buttonType: .left)
            }
            switch vm.currentTool {
            case let layerTool as LayerToolType:
                if vm.currentFilter != .none {
                    ImageProjectToolFilterFloatingSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                    Spacer()
                    ImageProjectToolFloatingButtonView(buttonType: .right)
                } else if layerTool == .crop {
                    ImageProjectViewFloatingCropSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                    Spacer()
                    ImageProjectToolFloatingButtonView(buttonType: .right)
                } else if layerTool == .draw {
                    if vm.isGradientViewPresented {
                        ImageProjectToolGradientFloatingSliderView(sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                    } else {
                        ImageProjectToolCaseDrawFloatingSliderView(sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                    }

                    Spacer()
                    ImageProjectToolFloatingButtonView(buttonType: .right)
                } else if layerTool == .background {
                    Spacer()
                    if vm.currentColorPickerType == .layerBackground {
                        if vm.isGradientViewPresented {
                            ImageProjectToolGradientFloatingSliderView(sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                        } else {
                            ImageProjectColorOpacityFloatingSliderView(
                                sliderHeight: vm.plane.lowerToolbarHeight * 0.5, colorPickerType: .layerBackground)
                        }
                    }
                    Spacer()
                    ImageProjectToolFloatingButtonView(buttonType: .right)
                } else if layerTool == .editText {
                    Spacer()
                    ImageProjectToolTextFloatingTextFieldView(textFieldHeight: vm.plane.lowerToolbarHeight * 0.5)
                    Spacer()
                }
            case let projectTool as ProjectToolType:
                switch projectTool {
                case .merge:
                    Spacer()
                    ImageProjectFloatingMergeSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5,
                        backgroundColor: $vm.projectModel.backgroundColor)
                    Spacer()
                case .text:
                    Spacer()
                    ImageProjectToolTextFloatingTextFieldView(textFieldHeight: vm.plane.lowerToolbarHeight * 0.5)
                    Spacer()
                case .background:
                    Spacer()
                    if vm.currentColorPickerType == .projectBackground {
                        if vm.isGradientViewPresented {
                            ImageProjectToolCaseDrawFloatingSliderView(
                                sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                        } else {
                            ImageProjectColorOpacityFloatingSliderView(
                                sliderHeight: vm.plane.lowerToolbarHeight * 0.5,
                                colorPickerType: .projectBackground)
                        }
                    }
                    Spacer()
                default:
                    EmptyView()
                }
            default:
                EmptyView()
            }
        }
        .offset(
            y: -(1 + 2 * vm.tools.paddingFactor) * vm.plane.lowerToolbarHeight * 0.5)
        .padding(.trailing, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .transition(.normalOpacityTransition)
    }
}
