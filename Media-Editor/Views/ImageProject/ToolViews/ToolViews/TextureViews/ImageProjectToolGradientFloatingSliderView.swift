//
//  ImageProjectToolGradientFloatingSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/05/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolGradientFloatingSliderView: View {
    @Environment(\.colorScheme) var appearance

    @EnvironmentObject var vm: ImageProjectViewModel

    let sliderHeight: CGFloat

    @State private var sliderWidth: Double = 0.0
    @State private var cancellable: AnyCancellable?

    @GestureState var lastOffset: [Double?] = Array(repeating: nil, count: 9)

    var maxOffset: Double { return sliderWidth - sliderHeight * 0.5 }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(
                    LinearGradient(gradient:
                        Gradient(
                            stops: vm.gradientModel.stops
                        ),
                        startPoint: .leading,
                        endPoint: .trailing)
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
            if vm.gradientModel.stops.count > 2 {
                let movableStops = Array($vm.gradientModel.stops.enumerated())[1 ... vm.gradientModel.stops.count - 2]
                ForEach(movableStops, id: \.0.self) { index, $stop in
                    let sliderOffset: Double = stop.location * maxOffset

                    Ellipse()
                        .fill(Color(appearance == .light ? .image : .tint))
                        .overlay {
                            Ellipse()
                                .fill(stop.color)
                                .padding(2)
                            Text(String(index + 1))
                                .foregroundStyle(stop.color.isDark ? Color(.tint) : Color(.accent))
                        }
                        .frame(width: sliderHeight * 0.5, height: sliderHeight)
                        .offset(x: sliderOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    var newOffset = lastOffset[index] ?? sliderOffset

                                    newOffset += value.translation.width
                                    newOffset = min(max(newOffset, 0.0), maxOffset)
                                    stop.location = newOffset / maxOffset
                                }
                                .updating($lastOffset) { _, lastOffset, _ in
                                    lastOffset[index] = lastOffset[index] ?? sliderOffset
                                }.onEnded { _ in
                                    vm.objectWillChange.send()
                                }
                        )
                }
            }
        }
        .transition(.normalOpacityTransition)
        .frame(maxWidth: .infinity, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
