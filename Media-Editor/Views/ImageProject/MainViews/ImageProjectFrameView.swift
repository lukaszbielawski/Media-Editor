//
//  ImageProjectFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var frameSize: CGSize = .init()
    @State var orientation: Image.Orientation = .up
    @State var frameViewRect: CGRect?

    @Binding var totalLowerToolbarHeight: Double?

    @Binding var geoProxy: GeometryProxy?

    let framePaddingFactor: Double

    var body: some View {
        if let geoProxy {
            ZStack {
                Image("AlphaVector")
                    .resizable(resizingMode: .tile)
                    .frame(width: frameSize.width, height: frameSize.height)
                    .shadow(radius: 10.0)
                    .onAppear {
                        guard let totalLowerToolbarHeight else { return }

                        frameSize = vm.calculateFrameSize(geoSize: geoProxy.size,
                                                          framePaddingFactor: framePaddingFactor,
                                                          totalLowerToolbarHeight: totalLowerToolbarHeight)

                        frameViewRect = vm.calculateFrameRect(frameSize: frameSize,
                                                              geo: geoProxy,
                                                              totalLowerToolbarHeight: totalLowerToolbarHeight)
                    }
                    .preference(key: ImageProjectFramePreferenceKey.self, value: frameViewRect)
            }
        }
    }
}
