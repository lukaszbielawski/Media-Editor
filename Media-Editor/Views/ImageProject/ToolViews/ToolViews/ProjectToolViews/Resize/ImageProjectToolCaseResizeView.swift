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

    let minPixels = 30
    let maxPixels = 9999

    @State var pixelFrameWidthTextField: String = ""
    @State var pixelFrameHeightTextField: String = ""
    @State var pixelFrameSliderWidth: CGFloat?
    @State var pixelFrameSliderHeight: CGFloat?

    @FocusState var isFocused: Bool

    var body: some View {
        HStack {
            if let pixelFrameSliderWidth = Binding($pixelFrameSliderWidth),
               let pixelFrameSliderHeight = Binding($pixelFrameSliderHeight)
            {
                VStack {
                    ImageProjectResizeSliderView(
                        hint: "width",
                        pixelFrameSliderDimension: pixelFrameSliderWidth,
                        pixelFrameDimensionTextField: $pixelFrameWidthTextField,
                        projectModelPixelFrameDimension: $vm.projectModel.framePixelWidth)
                        .focused($isFocused)
                    ImageProjectResizeSliderView(
                        hint: "height",
                        pixelFrameSliderDimension: pixelFrameSliderHeight,
                        pixelFrameDimensionTextField: $pixelFrameHeightTextField,
                        projectModelPixelFrameDimension: $vm.projectModel.framePixelHeight)
                        .focused($isFocused)
                }
            }
        }.onChange(of: isFocused) { newValue in
            if newValue {
                vm.tools.leftFloatingButtonAction = { isFocused = false }
                vm.tools.leftFloatingButtonIcon = "keyboard.chevron.compact.down"
            } else {
                vm.tools.leftFloatingButtonAction = { vm.currentTool = .none }
                vm.tools.leftFloatingButtonIcon = "arrow.uturn.backward"
            }
        }

        .onAppear {
            vm.tools.layersOpacity = 0.6
            pixelFrameHeightTextField = String(Int(vm.projectModel.framePixelHeight!))
            pixelFrameWidthTextField = String(Int(vm.projectModel.framePixelWidth!))
            pixelFrameSliderWidth = vm.projectModel.framePixelWidth!
            pixelFrameSliderHeight = vm.projectModel.framePixelHeight!
        }
        .onDisappear {
            vm.tools.layersOpacity = 1.0
        }
        .onTapGesture {
            isFocused = false
        }
        .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .padding(.bottom, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
