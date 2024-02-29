//
//  ImageProjectToolFullTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import SwiftUI

struct ImageProjectToolFullTileView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var title: String?
    let imageName: String
    var font: Font = .footnote

    var body: some View {
        Rectangle()
            .fill(Material.ultraThinMaterial)
            .overlay {
                ZStack(alignment: .bottom) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    if let title {
                        Text(title)
                            .foregroundStyle(Color(.tint))
                            .font(font)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(4.0)
                            .frame(maxWidth: .infinity)
                            .background(Material.ultraThinMaterial)
                    }
                }
            }
            .modifier(ProjectToolTileViewModifier())
    }
}
