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
    @State var pixelFrameSliderWidth: CGFloat?
    @State var pixelFrameSliderHeight: CGFloat?

    @FocusState var isFocused: Bool

    var body: some View {
        HStack {
            if let pixelFrameSliderWidth = Binding($pixelFrameSliderWidth),
               let pixelFrameSliderHeight = Binding($pixelFrameSliderHeight)
            {
                VStack {
                    HStack {
                        Slider(value: pixelFrameSliderWidth, in: 30 ... 9999, step: 1.0)
                            .layoutPriority(1)
                        TextField("width", text: $pixelFrameWidthTextField)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(minWidth: 50)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                            .onChange(of: pixelFrameWidthTextField) { newValue in
                                if let number = Int(newValue) {
                                    let validatedNumber: Int
                                    if number <= 30 {
                                        validatedNumber = 30
                                    } else if number >= 9999 {
                                        validatedNumber = 9999
                                    } else {
                                        validatedNumber = number
                                    }
                                    vm.projectModel.framePixelWidth = CGFloat(validatedNumber)
                                    pixelFrameWidthTextField = String(validatedNumber)
                                } else {
                                    pixelFrameWidthTextField = String(Int(vm.projectModel.framePixelWidth!))
                                }
                                vm.recalculateFrameAndLayersGeometry()
                            }
                            .onChange(of: pixelFrameSliderWidth.wrappedValue) { newValue in
                                vm.projectModel.framePixelWidth = newValue
                                pixelFrameWidthTextField = String(Int(newValue))
                                vm.recalculateFrameAndLayersGeometry()
                            }
                    }
                    HStack {
                        Slider(value: pixelFrameSliderHeight, in: 30 ... 9999, step: 1.0)
                            .layoutPriority(1)
                        TextField("height", text: $pixelFrameHeightTextField)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(minWidth: 50)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                            .onChange(of: pixelFrameHeightTextField) { newValue in
                                if let number = Int(newValue) {
                                    let validatedNumber: Int
                                    if number <= 30 {
                                        validatedNumber = 30
                                    } else if number >= 9999 {
                                        validatedNumber = 9999
                                    } else {
                                        validatedNumber = number
                                    }
                                    vm.projectModel.framePixelHeight = CGFloat(validatedNumber)
                                    pixelFrameHeightTextField = String(validatedNumber)
                                } else {
                                    pixelFrameHeightTextField = String(Int(vm.projectModel.framePixelHeight!))
                                }
                                vm.recalculateFrameAndLayersGeometry()
                            }
                            .onChange(of: pixelFrameSliderHeight.wrappedValue) { newValue in
                                vm.projectModel.framePixelHeight = newValue
                                pixelFrameHeightTextField = String(Int(newValue))
                                vm.recalculateFrameAndLayersGeometry()
                            }
                    }
                }
            }
        }.onAppear {
            pixelFrameHeightTextField = String(Int(vm.projectModel.framePixelHeight!))
            pixelFrameWidthTextField = String(Int(vm.projectModel.framePixelWidth!))
            pixelFrameSliderWidth = vm.projectModel.framePixelWidth!
            pixelFrameSliderHeight = vm.projectModel.framePixelHeight!
        }
        .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .padding(.bottom, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
