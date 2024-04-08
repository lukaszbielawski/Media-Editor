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
            ZStack {
                if let currentTool = vm.currentTool as? ProjectToolType {
                    switch currentTool {
                    case .add:
                        ImageProjectToolCaseAddView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    case .layers:
                        ImageProjectToolCaseLayersView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    case .merge:
                        ImageProjectToolCaseMergeView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    case .resize:
                        ImageProjectToolCaseResizeView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    case .text:
                        ImageProjectToolCaseTextView(isEditMode: false)
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    case .background:
                        ImageProjectToolCaseBackgroundView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    }
                } else if let currentTool = vm.currentTool as? LayerToolType, vm.activeLayer != nil {
                    switch currentTool {
                    case .filters:
                        ImageProjectToolCaseFiltersView()
                            .onAppear {
                                vm.tools.rightFloatingButtonIcon = "checkmark"
                                vm.leftFloatingButtonActionType = .back
                                vm.rightFloatingButtonActionType = .confirm
                            }
                    case .flip:
                        ImageProjectToolCaseFlipView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    case .crop:
                        ImageProjectToolCaseCropView()
                            .onAppear {
                                vm.leftFloatingButtonActionType = .exitFocusMode
                            }
                    case .background:
                        ImageProjectToolCaseBackgroundView(colorPickerType: .layerBackground)
                            .onAppear {
                                vm.leftFloatingButtonActionType = .exitFocusMode
                            }
                    case .editText:
                        ImageProjectToolCaseTextView(isEditMode: true)
                            .onAppear {
                                vm.leftFloatingButtonActionType = .back
                            }
                    }
                }
            }
            .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)

        }.onChange(of: vm.activeLayer == nil) { newValue in
            guard newValue else { return }

            if vm.currentTool is LayerToolType {
                vm.currentTool = .none
                vm.currentFilter = .none
                vm.currentCategory = .none
            }
        }
    }
}
