//
//  ImageProjectViewFloatingSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectViewFloatingFilterSliderView: View {
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState var lastOffset: Double?

    @State var sliderOffset: Double?
    @State var sliderWidth: Double = 0.0

    @State var sliderFactor: CGFloat?

    @State private var debounceSliderSubject = PassthroughSubject<Void, Never>()
    @State private var cancellable: AnyCancellable?

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
                if let sliderFactor {
                    return "\(Int(sliderFactor.toPercentage))%"
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
                    .fill(Color(appearance == .light ? .image : .tint))
                    .overlay {
                        Circle()
                            .fill(Color.tint)
                            .padding(2)
                        Text(percentage)
                            .foregroundStyle(Color(.image))
                    }
                    .frame(width: sliderHeight, height: sliderHeight)
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

                                sliderFactor = (sliderOffset / maxOffset)
                                debounceSliderSubject.send()
                            }
                            .updating($lastOffset) { _, lastOffset, _ in
                                lastOffset = lastOffset ?? sliderOffset
                            }
                    )
            }
            .onAppear {
                resetValues()
                cancellable =
                    debounceSliderSubject
                        .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                        .sink { [unowned vm] in
                            guard let currentFilter = vm.currentFilter,
                                  let sliderFactor,
                                  let filterParameterRangeAverage = currentFilter.parameterRangeAverage else { return }
                            let newFilterValue = sliderFactor * filterParameterRangeAverage
                            vm.currentFilter?.changeValue(value: newFilterValue)
                            Task {
                                await vm.applyFilter()
                            }
                            vm.objectWillChange.send()
                        }
            }.onReceive(vm.filterChangedSubject) {
                resetValues()
            }
        }
    }

    private func resetValues() {
        sliderOffset = nil
        sliderFactor = nil
    }
}
