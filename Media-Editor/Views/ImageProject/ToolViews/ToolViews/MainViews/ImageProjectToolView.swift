//
//  ImageProjectToolView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import SwiftUI

struct ImageProjectToolView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            ImageProjectToolScrollView()
            if let currentTool = vm.currentTool,
               !(currentTool is LayerSingleActionToolType)
            {
                ImageProjectToolDetailsView()
                    .transition(.normalOpacityTransition)
                    .zIndex(Double(Int.max) + 2)
                    .environmentObject(vm)
            }
            ImageProjectToolSettingsView()
        }
        .onReceive(vm.floatingButtonClickedSubject) { [weak vm] functionType in
            guard let vm else { return }
            if functionType == .back {
                if vm.currentTool == nil {
                    vm.deactivateLayer()
                }
                vm.currentTool = .none
                vm.currentColorPickerType = .none
            } else if functionType == .backFromColorPicker {
                vm.currentColorPickerType = .none
            } else if functionType == .backFromGradientPicker {
                vm.leftFloatingButtonActionType = .backFromColorPicker
                vm.isGradientViewPresented = false
                vm.setupInitialColorPickerColor()
            } else if functionType == .confirm {
                vm.isGradientViewPresented = false
                vm.setupInitialColorPickerColor()
            }
            print(functionType)
        }
        .overlay {
            if vm.isKeyboardOpen {
                Color.gray.opacity(0.4)
                    .transition(.normalOpacityTransition)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            }
        }
    }
}
