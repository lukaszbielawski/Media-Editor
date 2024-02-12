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
    @State var sliderWidth: Double = 0.0
    @State var isInteractive: Bool = true
    @State var alreadySwiped: Bool = false

    var maxOffset: Double { return sliderWidth - sliderHeight }
    let sliderHeight = 50.0

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(Color(vm.projectType.projectColor))
                .overlay(Material.ultraThinMaterial)
                .clipShape(Capsule(style: .circular))
                .frame(maxWidth: 300, maxHeight: sliderHeight)

                .overlay {
                    Label(vm.projectType == .photo ? "Create photo project" :
                            (vm.projectType == .movie ? "Create movie project" : "Choose media first")
                          , systemImage: "chevron.right.2")
                        .padding(.leading, 16)
                }
                .geometryAccessor { geo in
                    DispatchQueue.main.async {
                        sliderWidth = geo.size.width
                    }
                }

            Capsule(style: .circular)
                .fill(Color(vm.projectType.projectColor))
                .frame(width: sliderHeight + sliderOffset, height: sliderHeight)
            Circle()
                .fill(Color(.tint))
                .frame(width: sliderHeight, height: sliderHeight)
                .overlay {
                    Image(systemName: vm.projectType == .movie ? "film" : "photo")
                        .foregroundStyle(Color(vm.projectType.projectColor))
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
        .frame(maxWidth: 300)
        .padding(.horizontal, 50)
    }
}