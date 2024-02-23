//
//  ImageProjectViewFloatingSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import SwiftUI

struct ImageProjectViewFloatingSliderView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState var lastOffset: Double?

    @State var sliderOffset: Double?
    @State var sliderWidth: Double = 0.0

    var maxOffset: Double { return sliderWidth - sliderHeight }
    let sliderHeight: CGFloat

    var body: some View {
        if let currentFilter = vm.currentFilter, currentFilter.parameterName != nil {
            var defaultOffsetFactor: CGFloat {
                let defaultValue = currentFilter.parameterDefaultValue!
                let factor = defaultValue / currentFilter.parameterValueRange!.upperBound
                return factor
            }

            var percentage: String {
                if let sliderPercentage = vm.tools.sliderPercentage {
                    return "\(Int(sliderPercentage))%"
                } else {
                    return "\(Int(defaultOffsetFactor.toPercentage))%"
                }
            }

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
                    .frame(width: sliderHeight + (sliderOffset ?? (maxOffset * defaultOffsetFactor)),
                           height: sliderHeight)
                Circle()
                    .fill(Color(.tint))
                    .overlay {
                        Text(percentage)
                            .foregroundStyle(Color(.image))
                    }
                    .offset(x: sliderOffset ?? (maxOffset * defaultOffsetFactor))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                var newOffset = lastOffset ??
                                    (sliderOffset ?? (maxOffset * defaultOffsetFactor))

                                newOffset += value.translation.width
                                newOffset = min(max(newOffset, 0.0), maxOffset)
                                sliderOffset = newOffset
                                guard let sliderOffset else { return }

                                vm.tools.sliderPercentage = (sliderOffset / maxOffset).toPercentage
                            }
                            .updating($lastOffset) { _, lastOffset, _ in
                                lastOffset = lastOffset ?? sliderOffset
                            }
                    )
            }
        }
    }
}
