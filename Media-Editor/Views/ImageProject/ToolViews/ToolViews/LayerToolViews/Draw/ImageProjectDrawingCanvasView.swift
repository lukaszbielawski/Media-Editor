//
//  ImageProjectDrawingCanvasView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import Combine
import SwiftUI

struct ImageProjectDrawingCanvasView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var isTouchingCanvas = false
    @State private var pencilPosition: CGPoint = .zero

    @State private var touchingCanvasSubject =
        PassthroughSubject<Void, Never>()

    @State private var cancellable: AnyCancellable?

    let frameSize: CGSize
    let pixelSize: CGSize

    var initialOffset: CGSize {
        guard let workspaceSize = vm.workspaceSize else { return .zero }
        return CGSize(width: (workspaceSize.width - frameSize.width) * 0.5,
                      height: (workspaceSize.height - frameSize.height) * 0.5)
    }

    var body: some View {
        ZStack {
            ForEach(vm.drawings + [vm.currentDrawing], id: \.self) { drawing in
                let strokeStyle = StrokeStyle(lineWidth: CGFloat(drawing.currentPencilSize), lineCap: .round)

                Path { path in
                    drawing.setupPath(&path)
                }
                .pencilStroke(for: drawing, strokeStyle: strokeStyle)
                .blendMode(drawing.currentPencilType == .eraser ? .destinationOut : .normal)
                .clipShape(Rectangle().size(width: frameSize.width, height: frameSize.height))
            }
        }
        .contentShape(Rectangle())
        .frame(width: frameSize.width,
               height: frameSize.height)
        .border(Color.accentColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                .onChanged { value in
                    pencilPosition = value.location
                    touchingCanvasSubject.send()
                }
                .onEnded { [unowned vm] _ in
                    isTouchingCanvas = false
                    vm.storeCurrentDrawing()
                }
        )
        .onAppear {
            cancellable = touchingCanvasSubject
                .sink {
                    let particlePosition =
                        CGPoint(
                            x: pencilPosition.x
                                - initialOffset.width,
                            y: pencilPosition.y
                                - initialOffset.height
                        )
                    vm.currentDrawing.particlesPositions.append(particlePosition)
                }
        }
        .onReceive(vm.floatingButtonClickedSubject) { action in
            if action == .confirm {
                vm.currentTool = .none
                vm.currentColorPickerType = .none
                Task(priority: .userInitiated) { [unowned vm] in
                    await vm.applyDrawings(frameSize: frameSize)
                }

            } else if action == .exitFocusMode {
                vm.currentTool = .none
                vm.currentColorPickerType = .none
                vm.drawings.removeAll()
                vm.currentDrawing.particlesPositions.removeAll()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { [unowned vm] _ in
            guard isTouchingCanvas else { return }
            isTouchingCanvas = false
            vm.storeCurrentDrawing()
        }
    }
}
