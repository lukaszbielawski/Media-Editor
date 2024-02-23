//
//  ImageProjectToolDetailsView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolDetailsView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var isDeleteImageAlertPresented: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.image)
                .frame(height: vm.plane.lowerToolbarHeight)
            if let currentTool = vm.currentTool as? ProjectToolType {
                switch currentTool {
                case .add:
                    ImageProjectToolCaseAddView()
                case .layers:
                    ImageProjectToolCaseLayersView()
                case .resize:
                    ImageProjectToolCaseResizeView()
                }
            } else if let currentTool = vm.currentTool as? LayerToolType, vm.activeLayer != nil {
                switch currentTool {
                case .filters:
                    ImageProjectToolCaseFiltersView()
                        .onAppear {
                            vm.tools.rightFloatingButtonIcon = "checkmark"
                            vm.tools.rightFloatingButtonAction = {
                                vm.currentTool = .none
                            }
                        }
                case .flip:
                    ImageProjectToolCaseFlipView()
                }
            }

        }.onChange(of: vm.activeLayer == nil) { newValue in
            guard newValue else { return }

            if vm.currentTool is LayerToolType {
                vm.currentTool = .none
            }
        }
    }
}
