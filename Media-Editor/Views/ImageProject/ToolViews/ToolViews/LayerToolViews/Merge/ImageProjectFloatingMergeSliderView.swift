//
//  ImageProjectFloatingMergeSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/03/2024.
//

import Combine
import SwiftUI

struct ImageProjectFloatingMergeSliderView: View {
    @Environment(\.colorScheme) var appearance

    @EnvironmentObject var vm: ImageProjectViewModel

    let sliderHeight: CGFloat

    @State var isInteractive: Bool = true
    @State var alreadySwiped: Bool = false
    @State var sliderOffset: Double = 0.0
    @State private var sliderWidth: Double = 0.0
    @State private var cancellable: AnyCancellable?
    @Binding var backgroundColor: Color

    @GestureState var lastOffset: Double?

    var maxOffset: Double { return sliderWidth - sliderHeight }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(Color(.image))
                .overlay(Material.ultraThinMaterial)
                .clipShape(Capsule(style: .circular))
                .frame(maxWidth: 300, maxHeight: sliderHeight)

                .overlay {
                    Label(vm.layersToMerge.count < 2 ? "Select more layers" : "Merge layers",
                          systemImage: "chevron.right.2")
                    .animation(.easeInOut(duration: 0.35), value: vm.layersToMerge.count < 2)
                        .padding(.leading, 16)
                }
                .geometryAccessor { geo in
                    DispatchQueue.main.async {
                        sliderWidth = geo.size.width
                    }
                }
            Capsule(style: .circular)
                .fill(Color(.image))
                .frame(width: sliderHeight + sliderOffset, height: sliderHeight)
            Circle()
                .fill(Color(appearance == .light ? .image : .tint))
                .overlay {
                    Circle()
                        .fill(Color.tint)
                        .padding(2)
                    Text(String(vm.layersToMerge.count))
                        .font(.title2)
                        .foregroundStyle(Color(.image))
                }
                .frame(width: sliderHeight, height: sliderHeight)
                .offset(x: sliderOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !alreadySwiped else { return }

                            sliderOffset = min(max(value.translation.width, 0.0), maxOffset)
                            if sliderOffset > sliderWidth * 0.5 {
                                DispatchQueue.main.async {
                                    alreadySwiped = true
                                    isInteractive = false
                                    HapticService.shared.notify(.success)

                                    let animationDuration = (maxOffset - sliderOffset) / maxOffset

                                    withAnimation(Animation.easeOut(duration: animationDuration)) {
                                        sliderOffset = maxOffset
                                    }
                                }

                                Task {
                                    try await vm.mergeLayers()
                                    vm.currentTool = .none
                                }
                            }
                        }
                        .onEnded { _ in
                            if !alreadySwiped {
                                withAnimation(Animation.easeOut(duration: sliderOffset / maxOffset)) {
                                    sliderOffset = 0.0
                                }
                            }
                        }
                )
        }
        .frame(idealWidth: 200, maxWidth: 300)
        .overlay {
            Capsule(style: .circular)
                .fill(Color(.primary))
                .opacity(vm.layersToMerge.count < 2 ? 0.6 : 0.0)
        }
        .onAppear {
            vm.layersToMerge.removeAll()
        }.onDisappear {
            vm.layersToMerge.removeAll()
        }
    }
}
