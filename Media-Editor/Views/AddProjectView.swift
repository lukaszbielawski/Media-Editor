//
//  AddProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Kingfisher
import Photos
import SwiftUI

struct AddProjectView: View {
    @StateObject var vm = AddProjectViewModel()

    var body: some View {
        Text("Create a project using your Photo Library")
            .padding()
            .font(.title2)
        ScrollView(showsIndicators: false) {
            AddProjectGridView()
                .environmentObject(vm)
        }
    }
}

struct AddProjectGridView: View {
    @EnvironmentObject var vm: AddProjectViewModel

    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 4), count: UIDevice.current.userInterfaceIdiom == .phone ? 3 : 5)

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(vm.media, id: \.self) { media in
                    AddProjectGridTileView(media: media)
                }
            }
        }
        .padding(4)
        .onAppear {
            vm.requestAuthorization()
        }
    }
}

struct AddProjectGridTileView: View {
    let media: PHAsset
    @State var thumbnail: UIImage?
    var body: some View {
        ZStack {
            Group {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .centerCropped()

                        .aspectRatio(1.0, contentMode: .fill)
                        .cornerRadius(4.0)

                } else {
                    Color(.primary)
                        .aspectRatio(1.0, contentMode: .fill)
                        .cornerRadius(4.0)
                }
            }
        }
        .onAppear {
            media.getThumbnail(targetSize: .init(width: 100, height: 100), completion: { thumbnail in

                if let thumbnail {
                    let uuid = UUID()
                    self.thumbnail = thumbnail
                    media.getThumbnail(targetSize: [PHImageManagerMaximumSize, .init(width: 1000, height: 1000)].min()!, completion: { thumbnail in
                        if let thumbnail {
                            self.thumbnail = thumbnail
                        }
                    })
                }
            })
        }.onDisappear {
            thumbnail = nil
        }
    }
}

#Preview {
    AddProjectView()
}
