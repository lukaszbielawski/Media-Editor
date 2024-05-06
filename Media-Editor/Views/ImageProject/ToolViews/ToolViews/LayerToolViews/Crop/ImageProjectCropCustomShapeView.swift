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

//    var colorPickerBinding: Binding<Color?> {
//        return Binding<Color?> {
//            if let color = vm.currentShapeStyleModel.shapeStyle as? Color {
//                return color
//            } else {
//                return nil
//            }
//        } set: { color in
//            guard let color else { return }
//            vm.currentShapeStyleModel = ShapeStyleModel(shapeStyle: color, shapeStyleCG: UIColor(color).cgColor)
//        }
//    }

    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ImageProjectToolTileView(title: "Drag", iconName: "hand.draw.fill")
                        .onTapGesture {}
                    ImageProjectToolTileView(title: "Add dot", iconName: "circle.badge.plus.fill")
                        .onTapGesture {}
                    ImageProjectToolTileView(title: "Remove dot", iconName: "circle.badge.minus.fill")
                        .onTapGesture {}
                }
            }
            .onAppear { [unowned vm] in

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
