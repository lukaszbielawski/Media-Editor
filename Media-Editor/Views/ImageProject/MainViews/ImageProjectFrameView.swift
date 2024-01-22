//
//  ImageProjectFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var frameWidth: Double = 0.0
    @State var frameHeight: Double = 0.0
    @State var orientation: Image.Orientation = .up
    @State var frameViewRect: CGRect?

    @Binding var totalLowerToolbarHeight: Double?

    private let framePaddingFactor: Double = 0.05

    var geo: GeometryProxy?
    var body: some View {
        if let geo {
            ZStack {
                Image("AlphaVector")
                    .resizable(resizingMode: .tile)
                    .frame(width: frameWidth, height: frameHeight)
                    .shadow(radius: 10.0)
                    .onAppear {
                        guard let totalLowerToolbarHeight else { return }

                        let (width, height) = vm.project.getFrame()
                        let (geoWidth, geoHeight) =
                            (geo.size.width * (1.0 - 2 * framePaddingFactor),
                             (geo.size.height - totalLowerToolbarHeight) * (1.0 - 2 * framePaddingFactor))
                        let aspectRatio = height / width
                        let geoAspectRatio = geoHeight / geoWidth

                        if aspectRatio < geoAspectRatio {
                            frameWidth = geoWidth
                            frameHeight = geoWidth * aspectRatio
                        } else {
                            frameHeight = geoHeight
                            frameWidth = geoHeight / aspectRatio
                        }

                        let centerPoint =
                            CGPoint(x: geo.frame(in: .global).midX,
                                    y: geo.frame(in: .global).midY - totalLowerToolbarHeight * 0.5)

                        let topLeftCorner =
                            CGPoint(x: centerPoint.x - frameWidth * 0.5,
                                    y: centerPoint.y - frameHeight * 0.5)

                        frameViewRect =
                            CGRect(origin: topLeftCorner,
                                   size: CGSize(width: frameWidth, height: frameHeight))
                    }
                    .preference(key: ImageProjectFramePreferenceKey.self, value: frameViewRect)
            }
        }
    }
}
