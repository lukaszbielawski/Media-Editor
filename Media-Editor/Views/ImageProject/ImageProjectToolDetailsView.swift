//
//  ImageProjectToolDetailsView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolDetailsView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    let lowerToolbarHeight: Double
    let padding: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.accent)
                .frame(height: lowerToolbarHeight)

                .offset(x: 0, y: vm.currentTool == .none ? lowerToolbarHeight : 0)
                .animation(.easeOut(duration: 0.75), value: vm.currentTool)
            switch vm.currentTool {
            case .add:
                ScrollView(.horizontal) {
                    HStack {
                        ImageProjectToolTileView(systemName: "plus",
                                                 lowerToolbarHeight: lowerToolbarHeight,
                                                 padding: padding)
                        ForEach(vm.media) { item in
                            Image(uiImage: UIImage(cgImage: item.cgImage))
                                .centerCropped()
                                .modifier(ProjectToolTileViewModifier(
                                    lowerToolbarHeight: lowerToolbarHeight,
                                    padding: padding))
                        }
                    }
                }
                .padding(.horizontal, padding * lowerToolbarHeight)
            default:
                EmptyView()
            }
        }
    }
}
