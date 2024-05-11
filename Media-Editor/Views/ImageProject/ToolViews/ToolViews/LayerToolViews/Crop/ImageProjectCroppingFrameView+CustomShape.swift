//
//  ImageProjectCroppingFrameView+CustomShape.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/05/2024.
//

import Combine
import SwiftUI

extension ImageProjectCroppingFrameView {
    func customCroppingFrameView(pathPoints: [UnitPoint]) -> some View {
        ZStack {
            Path { path in
                let width = frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth
                let height = frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight

                for unitPoint in pathPoints {
                    let x = width * unitPoint.x
                    let y = height * unitPoint.y
                    if path.isEmpty {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()
            }
            .stroke(Color.accent, style: StrokeStyle(lineWidth: 2.0))
            .frame(width: frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth,
                   height: frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight)
            ZStack {
                ForEach(Array(pathPoints.enumerated()), id: \.self.0) { index, unitPoint in
                    let width = frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth
                    let height = frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight

                    let x = width * (unitPoint.x - 0.5)
                    let y = height * (unitPoint.y - 0.5)

                    Group {
                        if vm.cropModel.currentCropCustomShapeType == .removeDot {
                            PulsatingCircleView(systemName: "minus.circle.fill")
                                .onTapGesture {
                                    guard pathPoints.count > 3 else { return }

                                    var newPathPoints = pathPoints
                                    newPathPoints.remove(at: index)
                                    vm.cropModel.cropShapeType = .custom(pathPoints: newPathPoints)
                                    vm.updateLatestSnapshot()
                                }

                        } else {
                            Circle()
                                .fill(Color.accent)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .offset(.init(width: x,
                                  height: y))
                    .transition(.normalOpacityTransition)
                    .gesture(DragGesture()
                        .onChanged { value in
                            let position = value.location

                            let frameWidth = frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth
                            let frameHeight = frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight

                            let unitWidth = position.x / frameWidth

                            let unitHeight = position.y / frameHeight

                            let newUnitPoint = UnitPoint(x: unitWidth + 0.5, y: unitHeight + 0.5)

                            print(newUnitPoint)

                            changePathPointPosition(of: unitPoint,
                                                    for: newUnitPoint,
                                                    index: index,
                                                    pathPoints: pathPoints)
                        }
                        .onEnded { [unowned vm] _ in
                            vm.updateLatestSnapshot()
                        }
                    )

                    if vm.cropModel.currentCropCustomShapeType == .addDot {
                        let previousIndex = index == 0 ? pathPoints.count - 1 : index - 1

                        let previousPoint = CGPoint(x: width * (pathPoints[previousIndex].x - 0.5), y: height * (pathPoints[previousIndex].y - 0.5))
                        let midPoint = CGPoint(x: (x + previousPoint.x) / 2, y: (y + previousPoint.y) / 2)

                        PulsatingCircleView(systemName: "plus.circle.fill")
                            .offset(.init(width: midPoint.x,
                                          height: midPoint.y))
                            .transition(.normalOpacityTransition)
                            .onTapGesture {
                                let unitMidPoint = UnitPoint(x: midPoint.x / width + 0.5, y: midPoint.y / height + 0.5)
                                var newPathPoints = pathPoints
                                newPathPoints.insert(unitMidPoint, at: index)
                                vm.cropModel.cropShapeType = .custom(pathPoints: newPathPoints)
                                vm.updateLatestSnapshot()
                            }
                    }
                }
            }
        }
        .offset(offset)
    }

    struct PulsatingCircleView: View {
        @State var isAnimating: Bool = true

        let systemName: String

        var body: some View {
            Image(systemName: systemName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color(.accent), Color(.image))
                .scaleEffect(isAnimating ? 1.25 : 0.75)
                .animation(Animation.easeInOut(duration: 1.0).repeatForever(), value: isAnimating)
                .frame(width: 16, height: 16)
                .contentShape(Rectangle())
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                        isAnimating.toggle()
                    }
                }
        }
    }

    private func changePathPointPosition(of oldUnitPoint: UnitPoint,
                                         for newUnitPoint: UnitPoint,
                                         index: Int,
                                         pathPoints: [UnitPoint])
    {
        var newPathPoints = pathPoints
        newPathPoints[index] = newUnitPoint
        vm.cropModel.cropShapeType = .custom(pathPoints: newPathPoints)
    }
}
