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
                    HStack {
                        Color.clear
                            .frame(width: 16, height: 16)
                            .overlay {
                                Image(systemName: "minus")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                pixelFrameSliderWidth.wrappedValue -= 1.0
                            }
                        Slider
                            .withLog10Scale(value: pixelFrameSliderWidth,
                                            in: CGFloat(minPixels) ... CGFloat(maxPixels))
                            .layoutPriority(1)
                        Color.clear
                            .frame(width: 16, height: 16)
                            .overlay {
                                Image(systemName: "plus")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                pixelFrameSliderWidth.wrappedValue += 1.0
                            }
                        TextField("width", text: $pixelFrameWidthTextField)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(minWidth: 50)
                            .padding(.trailing)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                            .onChange(of: pixelFrameWidthTextField) { newValue in
                                if let number = Int(newValue) {
                                    let validatedNumber: Int
                                    if number <= 0 {
                                        validatedNumber = 1
                                    } else if number >= maxPixels {
                                        validatedNumber = maxPixels
                                    } else {
                                        validatedNumber = number
                                    }
                                    vm.projectModel.framePixelWidth = max(CGFloat(validatedNumber), 30)
                                    pixelFrameSliderWidth.wrappedValue = max(CGFloat(validatedNumber), 30)
                                } else {
                                    pixelFrameWidthTextField = ""
                                }
                                vm.recalculateFrameAndLayersGeometry()
                                vm.tools.centerButtonFunction?()
                            }
                            .onChange(of: pixelFrameSliderWidth.wrappedValue) { newValue in
                                vm.projectModel.framePixelWidth = newValue
                                pixelFrameWidthTextField = String(Int(newValue))

                                vm.recalculateFrameAndLayersGeometry()
                                vm.tools.centerButtonFunction?()
                            }
                    }
                    HStack {
                        Color.clear
                            .frame(width: 16, height: 16)
                            .overlay {
                                Image(systemName: "minus")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                pixelFrameSliderHeight.wrappedValue -= 1.0
                            }
                        Slider
                            .withLog10Scale(value: pixelFrameSliderHeight,
                                            in: CGFloat(minPixels) ... CGFloat(maxPixels))
                            .layoutPriority(1)
                        Color.clear
                            .frame(width: 16, height: 16)
                            .overlay {
                                Image(systemName: "plus")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                pixelFrameSliderHeight.wrappedValue += 1.0
                            }
                        TextField("height", text: $pixelFrameHeightTextField)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(minWidth: 50)
                            .padding(.trailing)
                            .multilineTextAlignment(.center)
                            .focused($isFocused)
                            .onChange(of: pixelFrameHeightTextField) { newValue in
                                if let number = Int(newValue) {
                                    let validatedNumber: Int
                                    if number <= 0 {
                                        validatedNumber = 1
                                    } else if number >= maxPixels {
                                        validatedNumber = maxPixels
                                    } else {
                                        validatedNumber = number
                                    }
                                    vm.projectModel.framePixelHeight = max(CGFloat(validatedNumber), 30)
                                    pixelFrameSliderHeight.wrappedValue = max(CGFloat(validatedNumber), 30)
                                } else {
                                    pixelFrameHeightTextField = ""
                                }
                                vm.recalculateFrameAndLayersGeometry()
                                vm.tools.centerButtonFunction?()
                            }
                            .onChange(of: pixelFrameSliderHeight.wrappedValue) { newValue in
                                vm.projectModel.framePixelHeight = newValue
                                pixelFrameHeightTextField = String(Int(newValue))

                                vm.recalculateFrameAndLayersGeometry()
                                vm.tools.centerButtonFunction?()
                            }
                    }
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
