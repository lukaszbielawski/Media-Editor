//
//  ImageProjectViewFloatingCropSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import Combine
import SwiftUI

struct ImageProjectViewFloatingCropSliderView: View {
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState var lastOffset: Double?

    @State private var sliderOffset: Double?
    @State private var sliderWidth: Double = 0.0

    @State private var debounceSliderSubject = PassthroughSubject<Void, Never>()
    @State private var cancellable: AnyCancellable?

    let count = Double(CropRatioType.allCases.count)

    var stepNumber: Double {
        floor((sliderOffset ?? defaultOffset) * (count - 1) / maxOffset)
    }

    var defaultOffsetFactor: CGFloat {
        ceil(count * 0.5) / count
    }

    var defaultOffset: CGFloat {
        maxOffset * defaultOffsetFactor
    }

    var stepOffset: Double {
        return stepNumber * maxOffset / (count - 1)
    }

    var maxOffset: Double { return sliderWidth - sliderHeight }
    let sliderHeight: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(Color(.image))
                .overlay(Material.ultraThinMaterial)
                .clipShape(Capsule(style: .circular))
                .geometryAccessor { geo in
                    DispatchQueue.main.async {
                        sliderWidth = geo.size.width
                    }
                }
            Capsule(style: .circular)
                .fill(Color(.image))
                .frame(width: sliderHeight + stepOffset,
                       height: sliderHeight)
            Circle()
                .fill(Color(appearance == .light ? .image : .tint))
                .overlay {
                    Circle()
                        .fill(Color.tint)
                        .padding(2)
                    Text(vm.currentCropRatio.text)
                        .foregroundStyle(Color(.image))
                }
                .frame(width: sliderHeight, height: sliderHeight)
                .offset(x: stepOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            var newOffset = lastOffset ??
                                (sliderOffset ?? (maxOffset * defaultOffsetFactor))
                            newOffset += value.translation.width
                            newOffset = min(max(newOffset, 0.0), maxOffset)
                            sliderOffset = newOffset
                        }
                        .updating($lastOffset) { _, lastOffset, _ in
                            lastOffset = lastOffset ?? sliderOffset
                        }
                )
        }
        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .transition(.normalOpacityTransition)
        .onChange(of: stepNumber) { value in
            HapticService.shared.play(.light)
            vm.currentCropRatio = CropRatioType.allCases[Int(value)]
        }
        .onAppear {
            resetValues()
        }
    }

    private func resetValues() {
        sliderOffset = nil
        vm.currentCropRatio = .any
        vm.currentCropShape = .rectangle
    }
}
