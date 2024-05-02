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

    var colorPickerType: ColorPickerType = .projectBackground
    var onlyCustom: Bool = false
    var allowOpacity: Bool = true
    var customTitle: String = "Custom"

    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                ColorPicker(selection: $vm.currentColorPickerBinding.onChange(colorPicked),
                            supportsOpacity: allowOpacity, label: { EmptyView() })
                    .labelsHidden()
                    .scaleEffect(vm.plane.lowerToolbarHeight *
                        (1 - 2 * vm.tools.paddingFactor) / (UIDevice.current.userInterfaceIdiom == .phone ? 28 : 36))
                ImageProjectToolColorTileView(color: $vm.currentColorPickerBinding, title: customTitle)
                    .allowsHitTesting(false)
            }
            if !onlyCustom {
                ForEach(vm.tools.colorArray, id: \.self) { color in
                    ImageProjectToolColorTileView(color: .constant(color))
                        .onTapGesture { [unowned vm] in
                            vm.currentColorPickerBinding = color
                            vm.performColorPickedAction(colorPickerType)
                        }
                }
                Spacer()
            }
        }.onAppear { [unowned vm] in
            vm.currentColorPickerBinding = {
                switch colorPickerType {
                case .projectBackground:
                    Color.clear
                case .layerBackground:
                    vm.projectModel.backgroundColor
                case .textColor:
                    Color.white
                case .borderColor:
                    Color.black
                case .pencilColor:
                    Color.red
                }
            }()

            cancellable =
                colorPickerSubject
                    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                    .sink { [unowned vm] colorPickerType in
                        vm.performColorPickedAction(colorPickerType)
                    }

            if colorPickerType == .layerBackground {
                guard let activeLayer = vm.activeLayer else { return }
                vm.originalCGImage = activeLayer.cgImage?.copy()
            }
        }
    }

    private func colorPicked(color: Color) {
        colorPickerSubject.send(colorPickerType)
    }
}
