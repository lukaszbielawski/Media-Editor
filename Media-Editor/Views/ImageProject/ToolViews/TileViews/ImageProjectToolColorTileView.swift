//
//  ImageProjectToolColorTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 25/02/2024.
//

import Foundation
import SwiftUI

struct ImageProjectToolColorTileView: View {
    @Environment(\.colorScheme) var appearance
    @Binding var color: Color
    var title: String?

    var body: some View {
        Rectangle()
            .fill(color)
            .background {
                Image("AlphaVector")
                    .resizable(resizingMode: .tile)
            }
            .overlay(alignment: .bottom) {
                if let title {
                    Text(title)
                        .foregroundStyle(Color(appearance == .light ? .image : .tint))
                        .font(.footnote)
                        .padding(4.0)
                        .frame(maxWidth: .infinity)
                        .background(Material.ultraThinMaterial)
                }
            }
            .modifier(ProjectToolTileViewModifier())
    }
}
