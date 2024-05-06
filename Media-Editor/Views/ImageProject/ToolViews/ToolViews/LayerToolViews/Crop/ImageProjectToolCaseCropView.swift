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
                    var title: String? = {
                        if case .custom = cropShapeType {
                            "Custom"
                        } else {
                            nil
                        }
                    }()
                    ImageProjectToolTileView(
                        title: title,
                        iconName: cropShapeType.iconName,
                        imageRotation: cropShapeType.isImageFlipped ? Angle(degrees: 180.0) : Angle(degrees: 0.0))
                        .centerCropped()
                        .overlay {
                            if vm.cropModel.cropShapeType == cropShapeType {
                                Color.accent
                                    .modifier(ProjectToolTileSelectedModifier(paddingFactor: vm.tools.paddingFactor, lowerToolbarHeight: vm.plane.lowerToolbarHeight))
                            }
                        }
                        .modifier(ProjectToolTileViewModifier())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.cropModel.cropShapeType = cropShapeType
                        }
                }
            }
        }
        .onReceive(vm.floatingButtonClickedSubject) { [unowned vm] newValue in
            if newValue == .backFromCustomShape {
                vm.cropModel.cropShapeType = .rectangle
            }
        }
    }
}
