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

    var body: some View {
        HStack {
            Color.clear
                .frame(width: 16, height: 16)
                .overlay {
                    Image(systemName: "minus")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    pixelFrameSliderDimension -= 1.0
                }
            Slider
                .withLog10Scale(value: $pixelFrameSliderDimension,
                                in: CGFloat(vm.frame.minPixels) ... CGFloat(vm.frame.maxPixels))
                .layoutPriority(1)
            Color.clear
                .frame(width: 16, height: 16)
                .overlay {
                    Image(systemName: "plus")
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    pixelFrameSliderDimension += 1.0
                }
            TextField(hint, text: $pixelFrameDimensionTextField)
                .keyboardType(.numberPad)
                .autocorrectionDisabled()
                .textFieldStyle(PlainTextFieldStyle())
                .frame(minWidth: 50)
                .padding(.trailing)
                .multilineTextAlignment(.center)
                .onChange(of: pixelFrameDimensionTextField) { newValue in
                    if let number = Int(newValue) {
                        let validatedNumber: Int
                        if number <= 0 {
                            validatedNumber = 1
                        } else if number >= vm.frame.maxPixels {
                            validatedNumber = vm.frame.maxPixels
                        } else {
                            validatedNumber = number
                        }
                        projectModelPixelFrameDimension = max(CGFloat(validatedNumber), 30)
                        debounceSaveSubject.send()
                        pixelFrameSliderDimension = max(CGFloat(validatedNumber), 30)

                    } else {
                        pixelFrameDimensionTextField = ""
                    }
                    vm.recalculateFrameAndLayersGeometry()
                    vm.tools.centerButtonFunction?()
                }
                .onChange(of: pixelFrameSliderDimension) { newValue in
                    projectModelPixelFrameDimension = newValue
                    debounceSaveSubject.send()

                    pixelFrameDimensionTextField = String(Int(newValue))

                    vm.recalculateFrameAndLayersGeometry()
                    vm.tools.centerButtonFunction?()
                }
        }
        .onAppear {
            cancellable = debounceSaveSubject
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .sink { _ in
                    vm.updateLatestSnapshot()
                    PersistenceController.shared.saveChanges()
                }
        }
    }
}
