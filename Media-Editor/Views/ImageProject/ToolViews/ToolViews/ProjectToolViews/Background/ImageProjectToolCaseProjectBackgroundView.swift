//
//  ImageProjectToolCaseProjectBackgroundView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/05/2024.
//

import Foundation
import SwiftUI

struct ImageProjectToolCaseProjectBackgroundView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    @FocusState var isFocused: Bool

    var body: some View {
        HStack {
            ImageProjectToolTileView(title: "Color", iconName: "paintpalette.fill")
                .onTapGesture {
                    vm.currentColorPickerType = .projectBackground
                }
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
                .padding(.bottom, vm.tools.paddingFactor *
                    vm.plane.lowerToolbarHeight)
                .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
            }
        }

        .onChange(of: isFocused) { [unowned vm] newValue in
            if newValue {
                vm.leftFloatingButtonActionType = .hideKeyboard
                vm.tools.leftFloatingButtonIcon = "keyboard.chevron.compact.down"
            } else {
                vm.leftFloatingButtonActionType = .back
                vm.tools.leftFloatingButtonIcon = "arrow.uturn.backward"
            }
        }
        .onReceive(vm.floatingButtonClickedSubject) { actionType in
            if actionType == .hideKeyboard {
                isFocused = false
            }
        }
        .onDisappear {
            vm.tools.layersOpacity = 1.0
        }
        .onTapGesture {
            isFocused = false
        }

    }
}

//struct ImageProjectToolCaseProjectBackgroundView: View {
//    @EnvironmentObject var vm: ImageProjectViewModel
//
//    var body: some View {
//        HStack {
//            ImageProjectToolTileView(title: "Color", iconName: "paintpalette.fill")
//                .onTapGesture {
//                    vm.currentColorPickerType = .projectBackground
//                }
//            Spacer()
//        }
//        .onAppear {
//            vm.currentColorPickerBinding = ShapeStyleModel(shapeStyle: vm.projectModel.backgroundColor,
//                                                           shapeStyleCG: vm.projectModel.backgroundColor.cgColor)
//        }
//    }
//}
