//
//  ImageProjectCroppingFrameView+CustomShape.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/05/2024.
//

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
            ForEach(Array(pathPoints.enumerated()), id: \.self.0) { index, unitPoint in
                let width = frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth
                let height = frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight

                Circle()
                    .fill(Color.accent)
                    .frame(width: 16, height: 16)
                    .offset(.init(width: width * (unitPoint.x - 0.5),
                                  height: height * (unitPoint.y - 0.5)))
                    .gesture(DragGesture()
                        .onChanged { value in
                            let position = value.location

                            let frameWidth = frameSize.width * frameScaleWidth * aspectRatioCorrectionWidth
                            let frameHeight = frameSize.height * frameScaleHeight * aspectRatioCorrectionHeight

                            let unitWidth = position.x / frameWidth

                            let unitHeight = position.y / frameHeight

                            let newUnitPoint = UnitPoint(x: unitWidth + 0.5, y: unitHeight + 0.5)

                            print(newUnitPoint)

                            changePathPointPosition(of: unitPoint, for: newUnitPoint,
                                                    index: index, pathPoints: pathPoints)
                        })
            }
        }
        .offset(offset)
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
