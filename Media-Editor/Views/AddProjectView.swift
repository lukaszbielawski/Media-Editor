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
                ForEach(vm.media) { media in
                    ZStack {
                        AddProjectGridTileView(media: media)
                    }
                }
            }
        }
        .padding(4)
    }
}

struct AddProjectGridTileView: View {
    @State var thumbnail: UIImage?
    @EnvironmentObject var vm: AddProjectViewModel
    @State var fetchTask: Task<Void, Error>?

    @State var media: PHAsset
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
            fetchTask = Task {
                do {
                    thumbnail = try await vm.fetchPhoto(for: media, desiredSize: .init(width: 100, height: 100))
                    thumbnail = try await vm.fetchPhoto(for: media, desiredSize: PHImageManagerMaximumSize)
                } catch {
                    print(error)
                }
            }
        }.onDisappear {
            fetchTask?.cancel()
            thumbnail = nil
        }
    }
}

#Preview {
    AddProjectView()
}
