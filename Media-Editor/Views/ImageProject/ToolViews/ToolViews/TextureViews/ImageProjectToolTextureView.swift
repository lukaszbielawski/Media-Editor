//
//  ImageProjectToolTextureView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolTextureView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var cancellable: AnyCancellable?
    @State private var colorPickerSubject = PassthroughSubject<ColorPickerType, Never>()
    @State private var onDisappearAction: FloatingButtonActionType?

    var onlyCustom: Bool = false
    var allowOpacity: Bool = true
    var customTitle: String = "Custom"

    var colorPickerBinding: Binding<Color?> {
        return Binding<Color?> {
            if let color = vm.currentColorPickerBinding.shapeStyle as? Color {
                return color
            } else {
                return nil
            }
        } set: { color in
            guard let color else { return }
            vm.currentColorPickerBinding = ShapeStyleModel(shapeStyle: color, shapeStyleCG: UIColor(color).cgColor)
        }
    }

    var body: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack {
                    if !vm.isGradientViewPresented {
                        if let colorPickerBinding = Binding(colorPickerBinding),
                           let colorPickerType = vm.currentColorPickerType
                        {
                            ImageProjectToolColorPickerView(colorPickerBinding: colorPickerBinding.onChange(colorPicked), customTitle: customTitle, allowOpacity: allowOpacity)
                            if colorPickerType.pickerType == .gradient {
                                ImageProjectToolTileView(title: "Gradient", iconName: "gradient")
                                    .onTapGesture {
                                        vm.isGradientViewPresented = true
                                    }
                            }
                            if colorPickerType.pickerType == .colorOpacity || colorPickerType.pickerType == .gradient {
                                ForEach(vm.tools.colorArray, id: \.self) { color in
                                    ImageProjectToolColorTileView(color: .constant(color))
                                        .onTapGesture { [unowned vm] in
                                            vm.currentColorPickerBinding =
                                                ShapeStyleModel(shapeStyle: color, shapeStyleCG: color.cgColor)
                                            vm.performColorPickedAction(colorPickerType, .debounce)
                                        }
                                }
                            }
                            Spacer()
                        }
                    } else {
                        ImageProjectToolGradientPickerView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .backFromGradientPicker
                            }
                    }
                }
            }
            .onAppear { [unowned vm] in
                vm.setupInitialColorPickerColor()

                cancellable =
                    colorPickerSubject
                        .throttleAndDebounce(throttleInterval: .seconds(1.0), debounceInterval: .seconds(1.0), scheduler: DispatchQueue.main)
                        .sink { [unowned vm] colorPickerType, throttleAndDebounceType in
                            vm.performColorPickedAction(colorPickerType, throttleAndDebounceType)
                        }
            }
        }

        .onAppear {
            onDisappearAction = vm.leftFloatingButtonActionType
            vm.leftFloatingButtonActionType = .backFromColorPicker
        }
        .onDisappear {
            if let onDisappearAction {
                vm.leftFloatingButtonActionType = onDisappearAction
            }
        }
    }

    private func colorPicked(color: Color) {
        guard let colorPickerType = vm.currentColorPickerType else { return }
        colorPickerSubject.send(colorPickerType)
    }
}
