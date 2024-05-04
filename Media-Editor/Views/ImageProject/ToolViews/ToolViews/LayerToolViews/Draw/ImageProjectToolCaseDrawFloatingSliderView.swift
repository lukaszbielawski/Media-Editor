//
//  ImageProjectToolCaseDrawFloatingSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import Combine
import Foundation
import SwiftUI

struct ImageProjectToolCaseDrawFloatingSliderView: View {
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

    let pencilSizeRange = 1.0 ... 100.0
    let defaultPencilSizeValue = 16.0

    var body: some View {
        var defaultOffsetFactor: CGFloat {
            let defaultValue = defaultPencilSizeValue
            let factor = (defaultValue - pencilSizeRange.lowerBound) /
                (pencilSizeRange.upperBound - pencilSizeRange.lowerBound)
            return factor
        }

//        var percentage: String {
//            if let sliderFactor {
//                return "\(Int(sliderFactor.toPercentage))%"
//            } else {
//                return "\(Int(defaultOffsetFactor.toPercentage))%"
//            }
//        }

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
                    Text("\(vm.currentDrawing.currentPencilSize)")
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
                            vm.currentDrawing.currentPencilSize = Int(sliderFactor! * 99.0) + 1
                            debounceSliderSubject.send()
                        }
                        .updating($lastOffset) { _, lastOffset, _ in
                            lastOffset = lastOffset ?? sliderOffset
                        }
                )
        }
        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .transition(.normalOpacityTransition)
    }
}
