//
//  ImageProjectColorOpacityFloatingSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectColorOpacityFloatingSliderView: View {
    @Environment(\.colorScheme) var appearance

    @EnvironmentObject var vm: ImageProjectViewModel

    let sliderHeight: CGFloat

    @State private var sliderWidth: Double = 0.0
    @State private var cancellable: AnyCancellable?

    var backgroundColor: Binding<Color?> {
        return Binding<Color?> {
            if let color = vm.currentColorPickerBinding.shapeStyle as? Color {
                return color
            } else {
                return nil
            }
        } set: { color in
            guard let color else { return }
            $vm.currentColorPickerBinding.wrappedValue = ShapeStyleModel(shapeStyle: color, shapeStyleCG: UIColor(color).cgColor)
        }
    }

    @GestureState var lastOffset: Double?

    var maxOffset: Double { return sliderWidth - sliderHeight }

    var sliderOffset: Double {
        guard let backgroundColor = backgroundColor.wrappedValue else { return 0.0 }
        return UIColor(backgroundColor).cgColor.alpha * maxOffset
    }

    var defaultOffsetFactor: CGFloat {
        guard let backgroundColor = backgroundColor.wrappedValue else { return 1.0 }
        return UIColor(backgroundColor).cgColor.alpha
    }

    var percentage: String {
        return "\(Int(defaultOffsetFactor.toPercentage))%"
    }

    let colorPickerType: ColorPickerType

    var body: some View {
        if let backgroundColor = Binding(backgroundColor) {
            ZStack(alignment: .leading) {
                Capsule(style: .circular)
                    .fill(
                        LinearGradient(
                            colors: [.clear, backgroundColor.wrappedValue.withAlpha(1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule(style: .circular))
                    .overlay {
                        Capsule(style: .circular)
                            .strokeBorder(Color(.secondary), lineWidth: 2)
                    }
                    .geometryAccessor { geo in
                        DispatchQueue.main.async {
                            sliderWidth = geo.size.width
                        }
                    }

                Circle()
                    .fill(Color(appearance == .light ? .image : .tint))
                    .overlay {
                        Circle()
                            .fill(Color.tint)
                            .padding(2)
                        Text(percentage)
                            .foregroundStyle(Color(.image))
                    }
                    .frame(width: sliderHeight, height: sliderHeight)
                    .offset(x: sliderOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                var newOffset = lastOffset ?? sliderOffset

                                newOffset += value.translation.width
                                newOffset = min(max(newOffset, 0.0), maxOffset)
                                backgroundColor.wrappedValue =
                                    backgroundColor.wrappedValue.withAlpha(newOffset / maxOffset)
                            }
                            .updating($lastOffset) { _, lastOffset, _ in
                                lastOffset = lastOffset ?? sliderOffset
                            }.onEnded { _ in
                                switch colorPickerType {
                                case .projectBackground:
                                    vm.updateLatestSnapshot()
                                default:
                                    Task {
                                        try await vm.addBackgroundToLayer()
                                    }
                                }

                                vm.objectWillChange.send()
                            }
                    )
            }
            .transition(.normalOpacityTransition)
            .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
            .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        }
    }
}
