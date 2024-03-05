//
//  ImageProjectToolCaseCropView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/03/2024.
//

import SwiftUI

struct ImageProjectToolCaseCropView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(CropShapeType.allCases, id: \.self) { cropShapeType in
                    ImageProjectToolTileView(
                        iconName: cropShapeType.iconName,
                        imageRotation: cropShapeType.isImageFlipped ? Angle(degrees: 180.0) : Angle(degrees: 0.0))
                        .onTapGesture {
                            vm.currentCropShape = cropShapeType
                        }
                        .contentShape(Rectangle())
                }
            }
        }
    }
}
