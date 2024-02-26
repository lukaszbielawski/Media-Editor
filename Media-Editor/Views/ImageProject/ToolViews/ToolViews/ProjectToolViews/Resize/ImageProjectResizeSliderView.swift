//
//  ImageProjectResizeSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectResizeSliderView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    let hint: String
    @Binding var pixelFrameSliderDimension: CGFloat
    @Binding var pixelFrameDimensionTextField: String
    @Binding var projectModelPixelFrameDimension: CGFloat?

    @State var debounceSaveSubject = PassthroughSubject<Void, Never>()
    @State var cancellable: AnyCancellable?

    @FocusState var isFocused

    var body: some View {
        HStack {
            Color.clear
                .frame(width: 16, height: 16)
                .overlay {
                    Image(systemName: "minus")
                        .foregroundStyle(Color(.tint))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if pixelFrameSliderDimension > CGFloat(vm.frame.minPixels) {
                        pixelFrameSliderDimension -= 1.0
                        debounceSaveSubject.send()
                    }
                }
            Slider
                .withLog10Scale(value: $pixelFrameSliderDimension.onChange(sliderChanged),
                                in: CGFloat(vm.frame.minPixels) ... CGFloat(vm.frame.maxPixels))
            { editing in
                if !editing {
                    print("updateslider")
                    vm.updateLatestSnapshot()
                    PersistenceController.shared.saveChanges()
                }
            }
            .layoutPriority(1)
            Color.clear
                .frame(width: 16, height: 16)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(.tint))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if pixelFrameSliderDimension < CGFloat(vm.frame.maxPixels) {
                        pixelFrameSliderDimension += 1.0
                        debounceSaveSubject.send()
                    }
                }
            TextField(hint,
                      text: $pixelFrameDimensionTextField.onChange(textFieldChanged), onEditingChanged: { editing in
                          if !editing {
                              print("updatetextfield")
                              vm.updateLatestSnapshot()
                              PersistenceController.shared.saveChanges()
                          }
                      })
                      .keyboardType(.numberPad)
                      .autocorrectionDisabled()
                      .textFieldStyle(PlainTextFieldStyle())
                      .foregroundStyle(Color(.tint))
                      .frame(minWidth: 50)
                      .padding(.trailing)
                      .multilineTextAlignment(.center)
        }
        .onAppear {
            vm.tools.layersOpacity = 0.6
            if hint == "width" {
                pixelFrameDimensionTextField = String(Int(vm.projectModel.framePixelWidth!))
            } else {
                pixelFrameDimensionTextField = String(Int(vm.projectModel.framePixelHeight!))
            }

            cancellable = debounceSaveSubject
                .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                .sink { _ in
                    print("update")
                    vm.updateLatestSnapshot()
                    PersistenceController.shared.saveChanges()
                }
        }
    }

    private func textFieldChanged(newValue: String) {
        if let number = Int(newValue) {
            let validatedNumber: Int
            if number <= 0 {
                validatedNumber = 1
            } else if number >= vm.frame.maxPixels {
                validatedNumber = vm.frame.maxPixels
            } else {
                validatedNumber = number
            }
            print(number)
            projectModelPixelFrameDimension = CGFloat(validatedNumber).rounded()
            pixelFrameSliderDimension = CGFloat(validatedNumber).rounded()

        } else {
            pixelFrameDimensionTextField = ""
        }
        vm.recalculateFrameAndLayersGeometry()
        vm.tools.centerButtonFunction?()
    }

    private func sliderChanged(newValue: CGFloat) {
        projectModelPixelFrameDimension = newValue
        pixelFrameDimensionTextField = String(Int(newValue))

        vm.recalculateFrameAndLayersGeometry()
        vm.tools.centerButtonFunction?()
    }
}
