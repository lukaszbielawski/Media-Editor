//
//  ImageProjectToolGradientPickerView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/05/2024.
//

import SwiftUI

struct ImageProjectToolGradientPickerView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    var allowOpacity: Bool = true

    var body: some View {
        HStack {
            ImageProjectToolTileView(
                title: "Direction",
                iconName: "arrow.up",
                imageRotation: vm.gradientModel.direction.rotationAngle)
                .onTapGesture {
                    vm.gradientModel.direction = vm.gradientModel.direction.nextClockwiseDirection
                }
            ForEach(Array($vm.gradientModel.stops.enumerated()), id: \.0.self) { index, $stop in
                ImageProjectToolColorPickerView(colorPickerBinding: $stop.color, allowOpacity: true)
                .overlay(alignment: .topLeading) {
                    if !(index == 0 || index == vm.gradientModel.stops.count - 1) {
                        Circle()
                            .fill(Color(.image))
                            .frame(width: 25, height: 25)
                            .padding(4.0)
                            .overlay {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color(.tint))
                            }
                            .padding(.top, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                removeControlPoint(at: index)
                            }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color(.image))
                        .frame(width: 25, height: 25)
                        .padding(4.0)
                        .overlay {
                            Text(String(index + 1))
                                .foregroundStyle(Color(.tint))
                        }
                        .padding(.top, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
                }
            }
            ImageProjectToolTileView(iconName: "plus")
                .onTapGesture {
                    addControlPoint()
                }
        }
        .onAppear { [unowned vm] in
            if let currentColor = vm.currentColorPickerBinding.shapeStyle as? Color {
                if vm.gradientModel.stops.count < 2 {
                    vm.gradientModel.stops =
                        [Gradient.Stop(color: currentColor, location: 0.0),
                         Gradient.Stop(color: currentColor.inverted.withAlpha(1.0), location: 1.0)]
                }
                setupGradientView()
            }
        }
        .onChange(of: vm.gradientModel) { _ in
            setupGradientView()
        }
    }

    private func setupGradientView() {
        if let gradient = vm.gradientModel.gradient, let gradientCG = vm.gradientModel.gradientCG {
            vm.currentColorPickerBinding =
                ShapeStyleModel(shapeStyle: gradient,
                                shapeStyleCG: gradientCG)
            if let colorPickerType = vm.currentColorPickerType {
                vm.performColorPickedAction(colorPickerType, .debounce)
            }
        }
    }

    private func addControlPoint() {
        guard vm.gradientModel.stops.count < 9 else { return }
        let randomColor = Color.random
        let stop = Gradient.Stop(color: randomColor, location: 0.5)
        vm.gradientModel.stops.append(stop)
        vm.gradientModel.stops.sort { $0.location < $1.location }
    }

    private func removeControlPoint(at index: Int) {
        vm.gradientModel.stops.remove(at: index)
    }
}
