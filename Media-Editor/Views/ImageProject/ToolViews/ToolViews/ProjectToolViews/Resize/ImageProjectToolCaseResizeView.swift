//
//  ImageProjectToolCaseResizeView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolCaseResizeView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    @State var pixelFrameWidthTextField: String = ""
    @State var pixelFrameHeightTextField: String = ""

    @FocusState var isFocused: Bool

    var body: some View {
        HStack {
            if let pixelFrameSliderWidth = Binding($vm.projectModel.framePixelWidth),
               let pixelFrameSliderHeight = Binding($vm.projectModel.framePixelHeight)
            {
                VStack {
                    ImageProjectResizeSliderView(
                        hint: "width",
                        pixelFrameSliderDimension: pixelFrameSliderWidth,
                        pixelFrameDimensionTextField:
                        pixelFrameSliderWidth.toString(),
                        projectModelPixelFrameDimension:
                        $vm.projectModel.framePixelWidth)
                        .focused($isFocused)
                    ImageProjectResizeSliderView(
                        hint: "height",
                        pixelFrameSliderDimension: pixelFrameSliderHeight,
                        pixelFrameDimensionTextField:
                        pixelFrameSliderHeight.toString(),
                        projectModelPixelFrameDimension:
                        $vm.projectModel.framePixelHeight)
                        .focused($isFocused)
                }
            }
        }.onChange(of: isFocused) { [unowned vm] newValue in
            if newValue {
                vm.leftFloatingButtonFunctionType = .hideKeyboard
                vm.tools.leftFloatingButtonIcon = "keyboard.chevron.compact.down"
            } else {
                vm.leftFloatingButtonFunctionType = .back
                vm.tools.leftFloatingButtonIcon = "arrow.uturn.backward"
            }
        }
        .onReceive(vm.floatingButtonClickedSubject) { [unowned vm] functionType in

            if functionType == .hideKeyboard {
                isFocused = false
            }
        }
        .onDisappear {
            vm.tools.layersOpacity = 1.0
        }
        .onTapGesture {
            isFocused = false
        }
        .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
