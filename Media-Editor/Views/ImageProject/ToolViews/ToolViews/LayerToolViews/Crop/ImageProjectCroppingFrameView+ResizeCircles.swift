//
//  ImageProjectCroppingFrameView+ResizeCircles.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/03/2024.
//

import SwiftUI

extension ImageProjectCroppingFrameView {
    var resizeFrame: some View {
        Color.clear
            .border(Color(.accent), width: resizeBorderWidth)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(Color(.accent))
                    .frame(width: resizeCircleSize, height: resizeCircleSize)
                    .offset(.init(
                        width: -(resizeCircleSize - resizeBorderWidth) * 0.5,
                        height: -(resizeCircleSize - resizeBorderWidth) * 0.5))
                    .gesture(resizeTopLeadingGesture)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
            }
            .overlay(alignment: .top) {
                if vm.currentCropRatio == .any {
                    Circle()
                        .fill(Color(.accent))
                        .frame(width: resizeCircleSize, height: resizeCircleSize)
                        .offset(.init(
                            width: 0,
                            height: -(resizeCircleSize - resizeBorderWidth) * 0.5))
                        .gesture(resizeTopGesture)
                }
            }
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color(.accent))
                    .frame(width: resizeCircleSize, height: resizeCircleSize)
                    .offset(.init(
                        width: (resizeCircleSize - resizeBorderWidth) * 0.5,
                        height: -(resizeCircleSize - resizeBorderWidth) * 0.5))
                    .gesture(resizeTopTrailingGesture)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
            }
            .overlay(alignment: .trailing) {
                if vm.currentCropRatio == .any {
                    Circle()
                        .fill(Color(.accent))
                        .frame(width: resizeCircleSize, height: resizeCircleSize)
                        .offset(.init(
                            width: (resizeCircleSize - resizeBorderWidth) * 0.5,
                            height: 0))
                        .gesture(resizeTrailingGesture)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(.accent))
                    .frame(width: resizeCircleSize, height: resizeCircleSize)
                    .offset(.init(
                        width: (resizeCircleSize - resizeBorderWidth) * 0.5,
                        height: (resizeCircleSize - resizeBorderWidth) * 0.5))
                    .gesture(resizeBottomTrailingGesture)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
            }
            .overlay(alignment: .bottom) {
                if vm.currentCropRatio == .any {
                    Circle()
                        .fill(Color(.accent))
                        .frame(width: resizeCircleSize, height: resizeCircleSize)
                        .offset(.init(
                            width: 0,
                            height: (resizeCircleSize - resizeBorderWidth) * 0.5))
                        .gesture(resizeBottomGesture)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(Color(.accent))
                    .frame(width: resizeCircleSize, height: resizeCircleSize)
                    .offset(.init(
                        width: -(resizeCircleSize - resizeBorderWidth) * 0.5,
                        height: (resizeCircleSize - resizeBorderWidth) * 0.5))
                    .gesture(resizeBottomLeadingGesture)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))

            }
            .overlay(alignment: .leading) {
                if vm.currentCropRatio == .any {
                    Circle()
                        .fill(Color(.accent))
                        .frame(width: resizeCircleSize, height: resizeCircleSize)
                        .offset(.init(
                            width: -(resizeCircleSize - resizeBorderWidth) * 0.5,
                            height: 0))
                        .gesture(resizeLeadingGesture)
                }
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
    }
}
