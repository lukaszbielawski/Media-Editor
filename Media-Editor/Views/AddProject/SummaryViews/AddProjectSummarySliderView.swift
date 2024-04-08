//
//  AddProjectSummarySliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import SwiftUI

struct AddProjectSummarySliderView: View {
    @EnvironmentObject var vm: AddProjectViewModel

    @State var sliderOffset: Double = 0.0

    @State var isInteractive: Bool = true
    @State var alreadySwiped: Bool = false

    var maxOffset: Double { return sliderWidth - sliderHeight }
    let sliderWidth: Double = 300.0
    let sliderHeight: Double = 50.0

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(Color(.image))
                .overlay(Material.ultraThinMaterial)
                .clipShape(Capsule(style: .circular))
                .frame(width: sliderWidth, height: sliderHeight)

                .overlay {
                    Label("Create photo project",
                          systemImage: "chevron.right.2")
                        .padding(.leading, 16)
                        .foregroundStyle(Color(.tint))
                }
            Capsule(style: .circular)
                .fill(Color(.image))
                .frame(width: sliderHeight + sliderOffset, height: sliderHeight)
            Circle()
                .fill(Color(.tint))
                .frame(width: sliderHeight, height: sliderHeight)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(Color(.image))
                }
                .offset(x: sliderOffset)
                .allowsHitTesting(isInteractive)
                .preference(key: ProjectCreatedPreferenceKey.self, value: vm.createdProject)
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

                                Task { try await vm.runCreateProjectTask() }
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
        .padding(.horizontal, 50)
    }
}
