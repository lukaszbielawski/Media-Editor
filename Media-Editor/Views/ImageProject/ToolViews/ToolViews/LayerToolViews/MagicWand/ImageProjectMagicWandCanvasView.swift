//
//  ImageProjectMagicWandCanvasView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import Combine
import SwiftUI

struct ImageProjectMagicWandCanvasView: View {
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
        Color
            .clear
            .contentShape(Rectangle())
            .frame(width: frameSize.width,
                   height: frameSize.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded { value in
                        let tapPosition = CGPoint(x: value.location.x - initialOffset.width, y: value.location.y - initialOffset.height)
                        Task(priority: .userInitiated) {
                            do {
                                try await vm.performMagicWandAction(tapPosition: tapPosition)
                            } catch {
                                print(error)
                            }
                        }
                    }
            )
            .onAppear {
                guard let activeLayer = vm.activeLayer else { return }
                vm.originalCGImage = activeLayer.cgImage?.copy()
            }
            .onReceive(vm.floatingButtonClickedSubject) { action in
                if action == .confirm {
                    guard let activeLayer = vm.activeLayer else { return }
                    vm.currentTool = .none
                    vm.currentColorPickerType = .none
                    Task {
                        try await vm.saveNewCGImageOnDisk(fileName: activeLayer.fileName, cgImage: activeLayer.cgImage)
                    }
                    vm.updateLatestSnapshot()
                    vm.leftFloatingButtonActionType = .back

                } else if action == .exitFocusMode {
                    vm.disablePreviewCGImage()
                    vm.currentTool = .none
                    vm.currentColorPickerType = .none
                }
            }
    }
}
