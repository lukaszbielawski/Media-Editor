//
//  ImageProjectToolCaseDrawView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct ImageProjectToolCaseDrawView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ImageProjectToolColorPickerView(
                    colorPickerType: .pencilColor,
                    onlyCustom: true,
                    allowOpacity: false,
                    customTitle: "Color")

                ForEach(PencilType.allCases, id: \.self) { pencilType in
                    ImageProjectToolTileView(
                        title: pencilType.name,
                        systemName: pencilType.icon)
                        .onTapGesture {
                            vm.currentPencil = pencilType
                        }
                        .contentShape(Rectangle())
                }
            }
        }
    }
}
