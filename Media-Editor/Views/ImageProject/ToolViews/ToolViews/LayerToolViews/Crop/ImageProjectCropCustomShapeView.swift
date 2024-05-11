//
//  ImageProjectCropCustomShapeView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/05/2024.
//

import Combine
import SwiftUI

struct ImageProjectCropCustomShapeView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var cancellable: AnyCancellable?
    @State private var colorPickerSubject = PassthroughSubject<ColorPickerType, Never>()
    @State private var onDisappearAction: FloatingButtonActionType?

    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(CropCustomShapeType.allCases, id: \.self) { cropShapeType in
                        ImageProjectToolTileView(title: cropShapeType.title, iconName: cropShapeType.iconName)
                            .centerCropped()
                            .overlay {
                                if vm.cropModel.currentCropCustomShapeType == cropShapeType {
                                    Color.accent
                                        .modifier(ProjectToolTileSelectedModifier(paddingFactor: vm.tools.paddingFactor, lowerToolbarHeight: vm.plane.lowerToolbarHeight))
                                }
                            }
                            .modifier(ProjectToolTileViewModifier())
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.cropModel.currentCropCustomShapeType = cropShapeType
                            }
                    }
                }
            }
        }

        .onAppear {
            onDisappearAction = vm.leftFloatingButtonActionType
            vm.leftFloatingButtonActionType = .backFromCustomShape

            if case .custom(let pathPoints) = vm.cropModel.cropShapeType {
                if pathPoints.isEmpty {
                    let initialPathPoints: [UnitPoint] = [.init(x: 0.0, y: 0.0),
                                                          .init(x: 1.0, y: 0.0),
                                                          .init(x: 1.0, y: 1.0),
                                                          .init(x: 0.0, y: 1.0)]
                    vm.cropModel.cropShapeType
                        = .custom(pathPoints: initialPathPoints)
                }
            }
        }
        .onDisappear {
            if let onDisappearAction {
                vm.leftFloatingButtonActionType = onDisappearAction
            }
        }
    }
}
