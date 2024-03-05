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
    let iconName: String
    var imageRotation: Angle = .zero

    var body: some View {
        Rectangle()
            .fill(Material.ultraThinMaterial)
            .overlay {
                VStack {
                    Spacer()
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal)
                        .rotationEffect(imageRotation)

                    if let title {
                        Text(title)
                            .font(.footnote)
                    }
                    Spacer()
                }  .padding(.vertical, 8)
            }
            .modifier(ProjectToolTileViewModifier())
    }
}
