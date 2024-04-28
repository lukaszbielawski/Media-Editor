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
    var iconName: String?
    var systemName: String?
    var imageRotation: Angle = .zero

    var body: some View {
        Rectangle()
            .fill(Material.ultraThinMaterial)
            .overlay {
                VStack(spacing: 0) {
                    Spacer()

                    if let systemName {
                        Image(systemName: systemName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .rotationEffect(imageRotation)
                    } else if let iconName {
                        Image(iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal)
                            .rotationEffect(imageRotation)
                    }

                    Spacer()
                    if let title {
                        Text(title)
                            .font(.footnote)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.vertical, 4)
            }
            .modifier(ProjectToolTileViewModifier())
    }
}
