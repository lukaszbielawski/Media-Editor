//
//  ImageProjectDrawingCanvasView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct ImageProjectDrawingCanvasView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @GestureState private var lastPencilOffset: CGSize? = .zero
    @GestureState var lastFrameScaleWidth: Double?
    @GestureState var lastFrameScaleHeight: Double?

    @State private var isTouchingCanvas = false
    @State private var wasTouchingCanvas = false

    @State var frameScaleWidth = 1.0
    @State var frameScaleHeight = 1.0

    @State private var pencilPosition: CGPoint = .zero

    let frameSize: CGSize
    let pixelSize: CGSize

    var aspectRatio: CGFloat {
        frameSize.width / frameSize.height
    }

    var initialOffset: CGSize {
        guard let workspaceSize = vm.workspaceSize else { return .zero }
        return CGSize(width: (workspaceSize.width - frameSize.width) * 0.5,
                      height: (workspaceSize.height - frameSize.height) * 0.5)
    }

    var body: some View {
        ZStack {
            Canvas { [unowned vm] context, _ in
                if isTouchingCanvas {
                    let circleRect = CGRect(
                        x: pencilPosition.x
                        - CGFloat(vm.currentPencilSize) / 2
                            - initialOffset.width,
                        y: pencilPosition.y
                            - CGFloat(vm.currentPencilSize) / 2
                            - initialOffset.height,
                        width: CGFloat(vm.currentPencilSize),
                        height: CGFloat(vm.currentPencilSize)
                    )
                    let particle: ParticleModel

                    particle = ParticleModel(
                        path: vm.currentPencil.path.path(in: circleRect),
                        color: vm.currentPencilColor
                    )

                    vm.drawingParticles.append(particle)
                }

                var path = Path()
                vm.drawingParticles.forEach { particle in
                    let particleRect = particle.path.boundingRect

                    path.addLine(to: .init(x: particleRect.midX, y: particleRect.midY))
                    path.move(to: .init(x: particleRect.midX, y: particleRect.midY))
                    context.fill(particle.path, with: .color(particle.color))
                    context.stroke(path, with: .color(particle.color), lineWidth: particleRect.width)
                }
            }
            .frame(width: frameSize.width * frameScaleWidth,
                   height: frameSize.height * frameScaleHeight)
            .border(Color.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                .onChanged { value in
                    isTouchingCanvas = true
                    pencilPosition = value.location
                }
                .onEnded { [unowned vm] _ in
                    isTouchingCanvas = false
                    Task(priority: .userInitiated) {
                        await vm.applyDrawings(frameSize: frameSize)
                    }
                }
        )
        .onReceive(vm.floatingButtonClickedSubject) { action in
            if action == .confirm {
//                Task {
//                    guard let activeLayer = vm.activeLayer else { return }
//                    vm.currentTool = .none
//                    vm.updateLatestSnapshot()
//                }
            }
        }
    }
}
