//
//  ImageProjectTextSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/04/2024.
//

import Combine
import SwiftUI

struct ImageProjectTextSliderView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    let hint: String
    let sliderRange: ClosedRange<CGFloat>
    let isLogarithmic: Bool
    @Binding var textSliderBinding: CGFloat
    @Binding var textTextFieldBinding: String

    @State var debounceSaveSubject = PassthroughSubject<SenderType, Never>()
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
                    if textSliderBinding > sliderRange.lowerBound {
                        textSliderBinding -= 1.0
                        debounceSaveSubject.send(.slider)
                    }
                }
            if isLogarithmic {
                Slider
                    .withLog10Scale(value: $textSliderBinding.onChange(sliderChanged),
                                    in: sliderRange.lowerBound ... sliderRange.upperBound)
                    .layoutPriority(1)
            } else {
                Slider(value: $textSliderBinding.onChange(sliderChanged),
                       in: sliderRange.lowerBound ... sliderRange.upperBound)
                    .layoutPriority(1)
            }

            Color.clear
                .frame(width: 16, height: 16)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundStyle(Color(.tint))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if textSliderBinding < sliderRange.upperBound {
                        textSliderBinding += 1.0
                        debounceSaveSubject.send(.slider)
                    }
                }
            TextField(hint,
                      text: $textTextFieldBinding.onChange(textFieldChanged), onEditingChanged: { editing in
                          if !editing {
                              vm.updateLatestSnapshot()
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
            textTextFieldBinding = String(Int(textSliderBinding))

            cancellable = debounceSaveSubject
                .map { value in
                    vm.objectWillChange.send()
                    return value
                }
                .throttleAndDebounce(throttleInterval: .seconds(0.0333),
                                     debounceInterval: .seconds(1.0),
                                     scheduler: DispatchQueue.main)
                .sink { [unowned vm] sender, publisherType in

                    vm.renderTask?.cancel()
                    vm.renderTask = Task {
                        try await vm.renderTextLayer()
                    }
                    if publisherType == .debounce && sender != .textField {
                        vm.updateLatestSnapshot()
                    }
                    vm.objectWillChange.send()
                }
        }
    }

    private func textFieldChanged(newValue: String) {
        if let number = Int(newValue) {
            let validatedNumber: Int
            if number <= 0 {
                validatedNumber = 1
            } else if number >= Int(sliderRange.upperBound) {
                validatedNumber = Int(sliderRange.upperBound)
            } else {
                validatedNumber = number
            }
            textSliderBinding = CGFloat(validatedNumber).rounded()

        } else {
            textTextFieldBinding = ""
        }
        withAnimation(.easeInOut(duration: 0.35)) {
            debounceSaveSubject.send(.textField)
        }
    }

    private func sliderChanged(newValue: CGFloat) {
        textTextFieldBinding = String(Int(newValue))
        debounceSaveSubject.send(.slider)
    }
}
