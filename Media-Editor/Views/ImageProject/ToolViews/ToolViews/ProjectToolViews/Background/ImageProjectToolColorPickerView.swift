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
    @State private var colorPickerSubject = PassthroughSubject<Void, Never>()

    var colorPickerType: ColorPickerType = .projectBackground
    var onlyCustom: Bool = false
    var allowOpacity: Bool = true
    var customTitle: String = "Custom"

    var body: some View {
        let colorBinding: Binding<Color>? = {
            switch colorPickerType {
            case .projectBackground:
                return $vm.projectModel.backgroundColor
            case .layerBackground:
                return $vm.currentLayerBackgroundColor
            case .textColor:
                if let textLayer = vm.activeLayer as? TextLayerModel {
                    return Binding<Color>(
                        get: {
                            textLayer.textColor
                        },
                        set: { newValue in
                            textLayer.textColor = newValue
                        }
                    )
                } else {
                    return nil
                }

            case .borderColor:
                if let textLayer = vm.activeLayer as? TextLayerModel {
                    return Binding<Color>(
                        get: {
                            textLayer.borderColor
                        },
                        set: { newValue in
                            textLayer.borderColor = newValue
                        }
                    )
                } else {
                    return nil
                }
            case .pencilColor:
                return $vm.currentPencilColor
            }

        }()

        if let colorBinding {
            HStack {
                ZStack(alignment: .center) {
                    ColorPicker(selection: colorBinding.onChange(colorPicked),
                                supportsOpacity: allowOpacity, label: { EmptyView() })
                        .labelsHidden()
                        .scaleEffect(vm.plane.lowerToolbarHeight *
                            (1 - 2 * vm.tools.paddingFactor) / (UIDevice.current.userInterfaceIdiom == .phone ? 28 : 36))
                    ImageProjectToolColorTileView(color: colorBinding, title: customTitle)
                        .allowsHitTesting(false)
                }
                if !onlyCustom {
                    ForEach(vm.tools.colorArray, id: \.self) { color in
                        ImageProjectToolColorTileView(color: .constant(color))
                            .onTapGesture {
                                colorBinding.wrappedValue = color
                                performColorPickedAction()
                            }
                    }
                    Spacer()
                }
            }.onAppear {
                cancellable =
                    colorPickerSubject
                        .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                        .sink {
                            performColorPickedAction()
                        }

                if colorPickerType == .layerBackground {
                    guard let activeLayer = vm.activeLayer else { return }
                    vm.originalCGImage = activeLayer.cgImage?.copy()
                }
            }
        }
    }

    private func colorPicked(color: Color) {
        colorPickerSubject.send()
    }

    private func performColorPickedAction() {

        switch colorPickerType {
        case .projectBackground:
            vm.updateLatestSnapshot()
        case .layerBackground:
            Task {
                try await vm.addBackgroundToLayer()
            }
        case .textColor, .borderColor:
            Task {
                try await vm.renderTextLayer()
            }
            vm.updateLatestSnapshot()
            vm.objectWillChange.send()
        case .pencilColor:
            break
        }
        vm.objectWillChange.send()
    }
}
