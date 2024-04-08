//
//  ImageProjectToolCaseTextSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/04/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolCaseTextSliderView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @FocusState var isFocused: Bool
    let textCategory: TextCategoryType

    var body: some View {
        ZStack(alignment: .bottom) {
            if let textLayerModel = vm.activeLayer as? TextLayerModel {
                let sliderBinding: Binding<CGFloat>?
                = switch textCategory
                {
                case .fontSize:
                    Binding<CGFloat>(
                        get: {
                            CGFloat(textLayerModel.fontSize)
                        },
                        set: { newValue in
                            textLayerModel.fontSize = Int(newValue)
                        }
                    )
                case .curve:
                    Binding<CGFloat>(
                        get: {
                            CGFloat(textLayerModel.curveAngle.degrees)
                        },
                        set: { newValue in
                            textLayerModel.curveAngle = Angle(degrees: newValue)
                        }
                    )
                case .border:
                    Binding<CGFloat>(
                        get: {
                            CGFloat(textLayerModel.borderSize)
                        },
                        set: { newValue in
                            textLayerModel.borderSize = Int(newValue)
                        }
                    )
                default:
                    nil
                }

                if let sliderBinding {
                    switch textCategory {
                    case .fontSize:
                        ImageProjectTextSliderView(
                            hint: "font size",
                            sliderRange: 10.0 ... 720.0,
                            isLogarithmic: true,
                            textSliderBinding: sliderBinding,
                            textTextFieldBinding:
                                sliderBinding.toString()
                        )
                        .focused($isFocused)
                    case .curve:
                        ImageProjectTextSliderView(
                            hint: "curve",
                            sliderRange: -180.0 ... 180.0,
                            isLogarithmic: false,
                            textSliderBinding: sliderBinding,
                            textTextFieldBinding:
                                sliderBinding.toString()
                        )
                        .focused($isFocused)
                    case .border:
                        ImageProjectTextSliderView(
                            hint: "border size",
                            sliderRange: -0.0 ... 36.0,
                            isLogarithmic: false,
                            textSliderBinding: sliderBinding,
                            textTextFieldBinding:
                                sliderBinding.toString()
                        )
                        .focused($isFocused)
                    default:
                        EmptyView()

                    }
                }
            }
        }
        .padding(.bottom, vm.tools.paddingFactor *
            vm.plane.lowerToolbarHeight)
        .frame(height: vm.plane.lowerToolbarHeight)
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
        .onTapGesture {
            isFocused = false
        }
        .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
