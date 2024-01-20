//
//  MenuTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import Kingfisher
import SwiftUI

struct MenuTileView: View {
    @Binding var project: ImageProjectEntity

    var dotsDidTapped: (UUID) -> Void
    var body: some View {
        ZStack(alignment: .top) {
            NavigationLink(destination: project.isMovie
                ? ImageProjectView(project: project)
                : ImageProjectView(project: project))
            {
                KFImage.url(project.thumbnailURL)
                    .centerCropped()
                    .aspectRatio(1.0, contentMode: .fill)
            }
            GeometryReader { geo in
                VStack {
                    ZStack {
                        Color(project.isMovie ? .accent : .accent2)
                            .opacity(0.8)
                            .frame(height: geo.size.height * 0.2)
                        HStack {
                            Image(systemName: project.isMovie ? "film" : "photo")
                            Text(project.formattedDate)
                            Image(systemName: "ellipsis.circle.fill")
                                .onTapGesture {
                                    dotsDidTapped(project.id!)
                                    HapticService.shared.play(.light)
                                }
                        }
                    }
                    Spacer()
                    HStack {
                        Text(project.title!)
                        Spacer()
                    }.padding(.vertical)
                        .padding(.leading, 8)
                }
            }
        }
    }
}
