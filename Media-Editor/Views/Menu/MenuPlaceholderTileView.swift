//
//  MenuPlaceholderTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import SwiftUI

struct MenuPlaceholderTileView: View {
    @State var isAddProjectViewPresented: Bool = false
    @State var createdProject: ProjectEntity?
    @State var activateNavigationLink: Bool = false
    @EnvironmentObject var vm: MenuViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .fill(Material.ultraThinMaterial)
                    .background {
                        Image("ex_image")
                            .centerCropped()
                    }
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

                NavigationLink(
                    destination: ProjectImageEditorView(project: createdProject),
                    isActive: $activateNavigationLink, label: {
                        EmptyView()
                    })
            }
        }
        .foregroundStyle(Color(.white))
        .aspectRatio(1.0, contentMode: .fill)
        .onTapGesture {
            isAddProjectViewPresented = true
            HapticService.shared.play(.medium)
        }

        .sheet(isPresented: $isAddProjectViewPresented) {
            AddProjectView()
                .onPreferenceChange(ProjectCreatedPreferenceKey.self) { value in
                    guard let value else { return }
                    
                    vm.projects.append(value)
                    createdProject = value
                    activateNavigationLink = true
                    vm.objectWillChange.send()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isAddProjectViewPresented = false
                    }
                }
                .onDisappear {
                    HapticService.shared.play(.medium)
                }
        }
    }
}
