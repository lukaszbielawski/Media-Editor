//
//  ImageProjectFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var orientation: Image.Orientation = .up
    
    let numberOfRows = 30
       let numberOfColumns = 30

    var body: some View {
        if vm.workspaceSize != nil {
            ZStack {
                Image("AlphaVector")
                    .resizable(resizingMode: .tile)
                    .frame(width: vm.frame.rect?.size.width ?? 0.0, height: vm.frame.rect?.size.height ?? 0.0)
                    .shadow(radius: 10.0)
                    .onAppear {
                        vm.setupFrameRect()
                    }
            }

        }
    }
}
