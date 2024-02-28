//
//  ImageProjectViewBackgroundSliderView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectFloatingBackgroundSliderView: View {
    @Environment(\.colorScheme) var appearance

    @EnvironmentObject var vm: ImageProjectViewModel

    let sliderHeight: CGFloat

    @State private var sliderWidth: Double = 0.0
    @State private var cancellable: AnyCancellable?

    @Binding var backgroundColor: Color
    @GestureState var lastOffset: Double?

    var maxOffset: Double { return sliderWidth - sliderHeight }

    var sliderOffset: Double {
        backgroundColor.cgColor!.alpha * maxOffset
    }

    var defaultOffsetFactor: CGFloat {
        return backgroundColor.cgColor?.alpha ?? 1.0
    }

    var percentage: String {
        return "\(Int(defaultOffsetFactor.toPercentage))%"
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(
                    LinearGradient(
                        colors: [.clear, backgroundColor.withAlpha(1.0)],
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
                            backgroundColor =
                                backgroundColor.withAlpha(newOffset / maxOffset)
                        }
                        .updating($lastOffset) { _, lastOffset, _ in
                            lastOffset = lastOffset ?? sliderOffset
                        }.onEnded { _ in
                            vm.updateLatestSnapshot()
                        }
                )
        }
    }
}
