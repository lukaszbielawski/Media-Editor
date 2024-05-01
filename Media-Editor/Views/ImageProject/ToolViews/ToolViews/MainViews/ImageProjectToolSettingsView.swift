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
                        .transition(.normalOpacityTransition)
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                } else if layerTool == .crop {
                    ImageProjectViewFloatingCropSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .transition(.normalOpacityTransition)
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                } else if layerTool == .draw {
                    ImageProjectToolCaseDrawFloatingSliderView(sliderHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .transition(.normalOpacityTransition)
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
                        .transition(.normalOpacityTransition)
                        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                    ImageProjectToolFloatingButtonView(
                        systemName: vm.tools.rightFloatingButtonIcon,
                        buttonType: .right)
                } else if layerTool == .editText {
                    Spacer()

                    ImageProjectToolTextFloatingTextFieldView(textFieldHeight: vm.plane.lowerToolbarHeight * 0.5)

                    Spacer()
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
                        .transition(.normalOpacityTransition)
                        .frame(maxWidth: 300, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
                        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                    Spacer()
                case .text:
                    Spacer()
                    ImageProjectToolTextFloatingTextFieldView(textFieldHeight: vm.plane.lowerToolbarHeight * 0.5)
                    Spacer()
                case .background:
                    Spacer()
                    ImageProjectFloatingBackgroundSliderView(
                        sliderHeight: vm.plane.lowerToolbarHeight * 0.5,
                        backgroundColor: $vm.projectModel.backgroundColor)
                        .transition(.normalOpacityTransition)
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
        .transition(.normalOpacityTransition)
        .onReceive(vm.floatingButtonClickedSubject) { [weak vm] functionType in
            guard let vm else { return }
            if functionType == .back {
                vm.currentTool = nil
            }
        }
    }
}
