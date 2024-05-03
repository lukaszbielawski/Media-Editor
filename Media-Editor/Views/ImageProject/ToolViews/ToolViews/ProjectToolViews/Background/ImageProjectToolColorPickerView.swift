//
//  ImageProjectToolColorPickerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 03/05/2024.
//

import SwiftUI

struct ImageProjectToolColorPickerView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    var colorPickerBinding: Binding<Color>
    let customTitle: String
    var allowOpacity: Bool


    var body: some View {
        ZStack(alignment: .center) {
            ColorPicker(selection: colorPickerBinding,
                        supportsOpacity: allowOpacity, label: { EmptyView() })
                .labelsHidden()
                .scaleEffect(vm.plane.lowerToolbarHeight *
                    (1 - 2 * vm.tools.paddingFactor) / (UIDevice.current.userInterfaceIdiom == .phone ? 28 : 36))
            ImageProjectToolColorTileView(color: colorPickerBinding, title: customTitle)
                .allowsHitTesting(false)
        }
    }
}
