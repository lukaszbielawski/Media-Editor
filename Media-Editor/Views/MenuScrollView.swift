//
//  MenuScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Kingfisher
import SwiftUI

struct MenuScrollView: View {
    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 16), count: UIDevice.current.userInterfaceIdiom == .phone ? 2 : 4)

    @EnvironmentObject var vm: MenuViewModel

    var dotsDidTapped: (UUID) -> ()

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                Group {
                    PlaceholderTileView()
                        .foregroundStyle(Color(.tint))

                    ForEach($vm.projects) { $project in
                        TileView(project: $project, dotsDidTapped: dotsDidTapped)
                    }
                    .foregroundStyle(Color(.white))
                }
                .cornerRadius(16.0)
            }
            .padding(16)
        }
    }
}

struct TileView: View {
    @Binding var project: ProjectEntity

    var dotsDidTapped: (UUID) -> ()
    var body: some View {
        ZStack(alignment: .top) {
            NavigationLink(destination: Text(project.title ?? "nil")) {
                KFImage.url(project.thumbnailURL)
                    .centerCropped()
                    .aspectRatio(1.0, contentMode: .fill)
            }
            GeometryReader { geo in
                VStack {
                    ZStack {
                        Color(project.isMovie ? .accent2 : .accent)
                            .opacity(0.8)
                            .frame(height: geo.size.height * 0.2)
                        HStack {
                            Image(systemName: project.isMovie ? "film" : "photo")
                            Text(project.formattedDate)
                            Image(systemName: "ellipsis.circle.fill")
                                .onTapGesture {
                                    dotsDidTapped(project.id!)
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

struct PlaceholderTileView: View {
    @State var isAddProjectViewPresented: Bool = false
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(.primary)
                    .centerCropped()

                VStack {
                    Spacer()
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: geo.size.width * 0.4)
                    Spacer()
                    Text("Create new project")
                }
                .padding(.vertical)
            }
        }
        .onTapGesture {
            isAddProjectViewPresented = true
        }
        .aspectRatio(1.0, contentMode: .fill)
        .sheet(isPresented: $isAddProjectViewPresented) {
            AddProjectView()
        }
    }
}

#Preview {
//    let preview = PersistenceController.shared.preview
//    let bindingArray: Binding<[ProjectEntity]> = .constant(preview)
    var vm = MenuViewModel()
    vm.projects = PersistenceController.preview.fetchAllProjects()
    return MenuScrollView { _ in }.environmentObject(vm)
}
