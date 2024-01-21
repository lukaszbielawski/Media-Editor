//
//  ImageProjectToolTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolTileView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var title: String?
    let systemName: String

    let lowerToolbarHeight: Double
    let padding: Double

    var body: some View {
        Rectangle()
            .fill(Material.ultraThinMaterial)
            .overlay {
                VStack {
                    Image(systemName: systemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal)
                    if let title {
                        Text(title)
                            .font(.footnote)
                    }
                }
            }
            .modifier(ProjectToolTileViewModifier(lowerToolbarHeight: lowerToolbarHeight, padding: padding))
    }
}
