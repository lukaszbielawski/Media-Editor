//
//  ImageProjectPlaneView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectPlaneView: View {
    @EnvironmentObject private var vm: ImageProjectViewModel

    @State private var scale = 1.0
    @State private var lastScaleValue = 1.0
    @State private var geoProxy: GeometryProxy?
    @State private var frameViewRect: CGRect?
    @State private var planeSize = CGSize()
    @State private var position = CGPoint()
    @State private var furthestPlanePointAllowed: CGPoint?
    @State private var initialPosition: CGPoint?

    @GestureState private var lastPosition: CGPoint?

    @Binding var totalNavBarHeight: Double?
    @Binding var totalLowerToolbarHeight: Double?
    @Binding var centerButtonTapped: (() -> Void)?

    let minScale = 1.0
    let maxScale = 10.0
    let previewMinScale = 0.2
    let previewMaxScale = 20.0

    let frameViewPadding = 16.0

    var body: some View {
        ZStack {
            Color.clear
                .frame(minWidth: planeSize.width,
                       maxWidth: .infinity,
                       minHeight: planeSize.height,
                       maxHeight: .infinity)

                .contentShape(Rectangle())
                .zIndex(Double(Int.min + 1))
                .geometryAccesor { geo in
                    DispatchQueue.main.async {
                        guard let totalLowerToolbarHeight, let totalNavBarHeight else { return }
                        print(geo.size)
                        geoProxy = geo
                        position =
                            CGPoint(x: geo.size.width / 2,
                                    y: (geo.size.height - totalLowerToolbarHeight) / 2 + totalNavBarHeight)
                        initialPosition = position
                        centerButtonTapped = self.centerPerspective
                        furthestPlanePointAllowed =
                            CGPoint(x: geo.size.width,
                                    y: geo.size.height + totalLowerToolbarHeight)
                    }
                }
            ImageProjectFrameView(totalLowerToolbarHeight: $totalLowerToolbarHeight, geo: geoProxy)
                .zIndex(Double(Int.min + 2))
        }
        .position(position)
        .onPreferenceChange(ImageProjectFramePreferenceKey.self) { frameViewRect in
            guard let frameViewRect, let geoProxy else { return }
            self.frameViewRect = frameViewRect
            planeSize =
                CGSize(width: frameViewRect.width + geoProxy.size.width * 2.0,
                       height: frameViewRect.height + geoProxy.size.height * 2.0)
        }

        .gesture(
            DragGesture()
                .onChanged { value in
                    var newPosition = lastPosition ?? position
                    newPosition.x += value.translation.width
                    newPosition.y += value.translation.height

                    position = validatePosition(newPosition: newPosition,
                                                frameViewPadding: 0).0 ?? position
                    print(position, UIScreen.topSafeArea.intFloor)
                }
                .updating($lastPosition) { _, startPosition, _ in
                    startPosition = startPosition ?? position
                }
                .onEnded { _ in
                    let edge = validatePosition(newPosition: position,
                                                frameViewPadding: frameViewPadding).1
                    if let edge {
                        print(edge)
                        withAnimation(Animation.linear(duration: 0.2)) {
                            switch edge {
                            case .leading(let offset):
                                position.x += offset
                            case .trailing(let offset):
                                position.x -= offset
                            case .top(let offset):
                                position.y += offset
                            case .bottom(let offset):
                                position.y -= offset
                            }
                        }
                    }
                }
        )
        .scaleEffect(scale)
        .animation(.bouncy(duration: 0.2), value: scale)
        .onTapGesture(count: 2) {
            if scale < 1.5 {
                scale = 2.0
            } else {
                scale = 1.0
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    DispatchQueue.main.async {
                        let delta = value / lastScaleValue
                        scale = min(max(scale * delta, previewMinScale), previewMaxScale)
                        lastScaleValue = value
                    }
                }
                .onEnded { _ in
                    if scale > maxScale {
                        scale = min(maxScale, scale)
                    } else {
                        scale = max(minScale, scale)
                    }

                    lastScaleValue = 1.0
                }
        )
    }

    private func centerPerspective() {
        guard let initialPosition else { return }
        let distance = hypot(position.x - initialPosition.x, position.y - initialPosition.y)

        let animationDuration: Double = distance / 2000.0 + 0.2

        withAnimation(.easeInOut(duration: animationDuration)) {
            position = initialPosition
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.linear(duration: 0.2)) {
                scale = 1.0
                //            }
            }
        }
    }

    func validatePosition(newPosition: CGPoint, frameViewPadding: Double) -> (CGPoint?, EdgeOffset?)
    {
        guard let furthestPlanePointAllowed,
              let frameViewRect,
              let totalNavBarHeight,
              let totalLowerToolbarHeight
        else {
            return (newPosition, nil)
        }

        let (newX, newY) = (newPosition.x, newPosition.y)
        let (maxX, maxY) =
            (furthestPlanePointAllowed.x + frameViewRect.width / 2,
             furthestPlanePointAllowed.y -
                 totalLowerToolbarHeight + frameViewRect.height / 2)
        print(totalNavBarHeight)
        let (minX, minY) =
            (-frameViewRect.width / 2,
             -frameViewRect.height / 2 + totalNavBarHeight)

        if minX + frameViewPadding > newX {
            let diff = minX + frameViewPadding - newX
            return (nil, .leading(offset: diff))
        } else if maxX - frameViewPadding < newX {
            let diff = newX - maxX + frameViewPadding

            return (nil, .trailing(offset: diff))
        }

        if minY + frameViewPadding > newY {
            let diff = minY + frameViewPadding - newY
            return (nil, .top(offset: diff))
        } else if maxY - frameViewPadding < newY {
            let diff = newY - maxY + frameViewPadding
            return (nil, .bottom(offset: diff))
        }

        return (newPosition, nil)
    }
}
