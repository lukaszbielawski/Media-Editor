//
//  ImageProjectToolColorPickerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolColorPickerView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var cancellable: AnyCancellable?
    @State private var colorPickerSubject = PassthroughSubject<ColorPickerType, Never>()

    let colorPickerType: ColorPickerType
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
        if let colorPickerBinding = Binding(colorPickerBinding) {
            HStack {
                ZStack(alignment: .center) {
                    ColorPicker(selection: colorPickerBinding.onChange(colorPicked),
                                supportsOpacity: allowOpacity, label: { EmptyView() })
                        .labelsHidden()
                        .scaleEffect(vm.plane.lowerToolbarHeight *
                            (1 - 2 * vm.tools.paddingFactor) / (UIDevice.current.userInterfaceIdiom == .phone ? 28 : 36))
                    ImageProjectToolColorTileView(color: colorPickerBinding, title: customTitle)
                        .allowsHitTesting(false)
                }
                if !onlyCustom {
                    ForEach(vm.tools.colorArray, id: \.self) { color in
                        ImageProjectToolColorTileView(color: .constant(color))
                            .onTapGesture { [unowned vm] in
                                vm.currentColorPickerBinding =
                                    ShapeStyleModel(shapeStyle: color, shapeStyleCG: color.cgColor)
                                vm.performColorPickedAction(colorPickerType, .debounce)
                            }
                    }

                    Spacer()
                }
            }.onAppear { [unowned vm] in
                vm.currentColorPickerType = colorPickerType
                vm.setupInitialColorPickerColor()

                cancellable =
                    colorPickerSubject
                        .throttleAndDebounce(throttleInterval: .seconds(1.0), debounceInterval: .seconds(1.0), scheduler: DispatchQueue.main)
                        .sink { [unowned vm] colorPickerType, throttleAndDebounceType in
                            vm.performColorPickedAction(colorPickerType, throttleAndDebounceType)
                        }

                if vm.currentColorPickerType == .layerBackground {
                    guard let activeLayer = vm.activeLayer else { return }
                    vm.originalCGImage = activeLayer.cgImage?.copy()
                }
            }
        }
    }

    private func colorPicked(color: Color) {
        colorPickerSubject.send(vm.currentColorPickerType)
    }
}
