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
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                    .zIndex(Double(Int.max) + 2)
                    .environmentObject(vm)
            }
            ImageProjectToolSettingsView()
        }
    }
}
