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
        Canvas { [unowned vm] context, _ in
            if isTouchingCanvas {
                let particlePosition =
                    CGPoint(
                        x: pencilPosition.x
                            - initialOffset.width,
                        y: pencilPosition.y
                            - initialOffset.height
                    )
                vm.pencil.particlesPositions.append(particlePosition)
            }

            var path = Path()

            vm.pencil.particlesPositions.forEach { position in
                path.addLine(to: .init(x: position.x, y: position.y))
                path.move(to: .init(x: position.x, y: position.y))
            }

            let strokeStyle = StrokeStyle(lineWidth: CGFloat(vm.pencil.currentPencilSize), lineCap: .round)
            let pencilColor: GraphicsContext.Shading = .color(vm.pencil.currentPencilType == .eraser ? Color.black : vm.pencil.currentPencilColor)

            context.stroke(path,
                           with: pencilColor,
                           style: strokeStyle)
        }
        .frame(width: frameSize.width * frameScaleWidth,
               height: frameSize.height * frameScaleHeight)

        .blendMode(vm.pencil.currentPencilType == .eraser ? .destinationOut : .normal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                .onChanged { value in
                    isTouchingCanvas = true
                    pencilPosition = value.location
                }
                .onEnded { _ in
                    isTouchingCanvas = false
                    Task(priority: .userInitiated) { [unowned vm] in
                        await vm.applyDrawings(frameSize: frameSize)
                    }
                }
        )
    }
}
