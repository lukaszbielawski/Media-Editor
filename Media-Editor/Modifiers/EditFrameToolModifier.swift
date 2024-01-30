//
//  EditFrameToolModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation
import SwiftUI

struct EditFrameToolModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    let isActive: Bool
    let geoSize: CGSize
    let planeSize: CGSize
    var totalNavBarHeight: Double?

    @Binding var rotation: Angle?
    @Binding var position: CGPoint?

    @GestureState var lastAngle: Angle?
    @GestureState var lastPosition: CGPoint?

    @Binding var scaleX: Double?
    @Binding var scaleY: Double?
    @State var opacity = 0.0
    @State var isVisible = false
    var editAction: (EditType) -> Void

    func body(content: Content) -> some View {
        ZStack {
            if isVisible {
                RoundedRectangle(cornerRadius: 2.0)

                    .fill(Color(.image))
                    .padding(14)
                    .frame(width: width * abs(scaleX ?? 1.0) + 42, height: height * abs(scaleY ?? 1.0) + 42)
                    .opacity(opacity)
                    .overlay {
                        content
                            .modifier(LayerTransformationModifier(scaleX: scaleX, scaleY: scaleY))
                    }
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "xmark")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .contentShape(Circle())
                            .onTapGesture {
                                editAction(.delete)
                            }
                    }
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .top))
                            .opacity(opacity)
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in

                                }
                                .updating($lastPosition) { _, lastPosition, _ in
                                    lastPosition = lastPosition ?? position
                                }
                                .onEnded { _ in
                                    editAction(.save)
                                }
                            )
                    }
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "crop.rotate")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .onTapGesture {
                                if rotation != nil {
                                    editAction(.rotateLeft)
                                }
                            }
                            .gesture(DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    guard let position, let totalNavBarHeight else { return }
                                    let centerPoint = CGPoint(x: position.x - planeSize.width * 0.5,
                                                              y: position.y - planeSize.height * 0.5)

                                    let currentDragPoint =
                                        CGPoint(x: value.location.x - geoSize.width / 2,
                                                y: value.location.y - (geoSize.height + totalNavBarHeight) / 2)

                                    let previousDragPoint =
                                        CGPoint(x: value.startLocation.x - geoSize.width / 2,
                                                y: value.startLocation.y - (geoSize.height + totalNavBarHeight) / 2)

                                    let currentAngle =
                                        Angle(radians: atan2(currentDragPoint.x - centerPoint.x,
                                                             currentDragPoint.y - centerPoint.y))
                                    let previousAngle =
                                        Angle(radians: atan2(previousDragPoint.x - centerPoint.x,
                                                             previousDragPoint.y - centerPoint.y))

                                    let angleDiff = currentAngle - previousAngle

                                    let newAngle = -(lastAngle ?? rotation ?? .zero) + angleDiff

                                    editAction(.rotation(angle: -newAngle))
                                }
                                .updating($lastAngle) { _, lastAngle, _ in
                                    lastAngle = lastAngle ?? rotation
                                }
                                .onEnded { _ in
                                    editAction(.save)
                                })
                    }
                    .overlay(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .trailing))
                            .opacity(opacity)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    editAction(.aspectResize(translation: value.translation))
                                }
                                .onEnded { _ in
                                    editAction(.save)
                                }
                            )
                    }
                    .overlay(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .bottom))
                            .opacity(opacity)
                    }
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill")
                            .modifier(EditFrameCircleModifier())
                            .shadow(radius: 10.0)
                            .opacity(opacity)
                            .onTapGesture {
//                                self.scaleY! *= -1
                                editAction(.flip)
                                editAction(.save)
                            }
                    }
                    .overlay(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                        Circle()
                            .strokeBorder(Color(.image), lineWidth: 2)
                            .clipShape(Circle())
                            .modifier(EditFrameResizeModifier(edge: .leading))
                            .opacity(opacity)
                    }
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.35)) {
                            opacity = 1.0
                        }
                    }
            } else {
                content
                    .modifier(LayerTransformationModifier(scaleX: scaleX, scaleY: scaleY))
            }
        }
        .onChange(of: isActive) { value in
            if value {
                isVisible = true
            } else {
                withAnimation(.easeOut(duration: 0.35)) {
                    opacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isVisible = false
                }
            }
        }
    }
}

struct EditFrameCircleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content

            .frame(width: 16, height: 16)
            .padding(10)
            .background(Circle().fill(Color(.image)))
    }
}

struct LayerTransformationModifier: ViewModifier {
    let scaleX: Double?
    let scaleY: Double?

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: (scaleX ?? 1.0) < 0 ? -1.0 : 1.0, y: (scaleY ?? 1.0) < 0 ? -1.0 : 1.0)
            .scaleEffect(x: abs(scaleX ?? 1.0), y: abs(scaleY ?? 1.0))
    }
}

struct EditFrameResizeModifier: ViewModifier {
    let edge: Edge.Set

    func body(content: Content) -> some View {
        ZStack {
            Circle()
                .fill(Color(.tint))
                .frame(width: 13, height: 13)
            content
                .frame(width: 14, height: 14)
                .padding(5)
        }
        .padding(edge, 2)
    }
}
