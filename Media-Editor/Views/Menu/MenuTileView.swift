//
//  MenuTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import SwiftUI

struct MenuTileView: View {
    let project: ImageProjectEntity

    var dotsDidTapped: (UUID) -> Void
    @State var image: UIImage?

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                VStack {
                    ZStack {
                        Color(.image)
                            .opacity(0.8)
                            .frame(height: geo.size.height * 0.2)
                        HStack {
                            Image(systemName: "photo")
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
                            .padding(.horizontal, 4.0)
                            .padding(4.0)
                            .background(Color(.image), in: RoundedRectangle(cornerRadius: 8.0))
                            .opacity(0.8)
                            .foregroundStyle(Color(.tint))
                        Spacer()
                    }.allowsHitTesting(false)
                    .padding(.vertical, 8)
                        .padding(.leading, 8)
                }
            }
            .aspectRatio(1.0, contentMode: .fill)
            .background {
                NavigationLink(destination: ImageProjectView(project: project)) {
                    ZStack {

                        Color.clear
                            .padding(2)

                            .contentShape(RoundedRectangle(cornerRadius: 16.0))
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()

                        } else {
                            Image("PlaceholderImage")
                                .resizable()
                                .scaledToFit()
                        }
                        RoundedRectangle(cornerRadius: 16.0)
                            .strokeBorder(Color(.image), style: StrokeStyle(lineWidth: 2))
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .onAppear {
            if let imageData = try? Data(contentsOf: project.thumbnailURL) {
                image = UIImage(data: imageData)
            }
        }
    }
}
