//
//  ImageProjectToolCaseLayerBackgroundView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/05/2024.
//

import SwiftUI

struct ImageProjectToolCaseLayerBackgroundView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        HStack {
            ImageProjectToolTileView(title: "Color", iconName: "paintpalette.fill")
                .onTapGesture {
                    vm.currentColorPickerType = .layerBackground
                }
            Spacer()
        }
        .onAppear {
            guard let activeLayer = vm.activeLayer else { return }
            vm.originalCGImage = activeLayer.cgImage?.copy()
        }.onReceive(vm.floatingButtonClickedSubject) { [unowned vm] action in
            if action == .back {
                vm.activeLayer?.cgImage = vm.originalCGImage
            }
        }
    }
}
