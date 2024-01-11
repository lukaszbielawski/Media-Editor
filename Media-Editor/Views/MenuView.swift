//
//  MenuView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/01/2024.
//

import CoreData
import Kingfisher
import SwiftUI

struct MenuView: View {
    @State var isManageProjectSheetPresented: Bool = false
    @StateObject var vm = MenuViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geo in
                    VStack {
                        UpperMenuView()
                            .frame(height: geo.size.height * 2 / 5)
                        MenuScrollView { id in
                            let project = PersistenceController.shared.fetchProject(withID: id)
                            vm.selectedProject = project
                            isManageProjectSheetPresented = true
                        }
                        .environmentObject(vm)
                    }
                }

                ManageProjectSheetView(isManageProjectSheetPresented: $isManageProjectSheetPresented)
                    .environmentObject(vm)
                    .gesture(DragGesture().onEnded { value in
                        if value.translation.height > 50 {
                            isManageProjectSheetPresented = false
                        }
                    })
            }
        }.navigationViewStyle(.stack)
    }
}

struct UpperMenuView: View {
    var body: some View {
        Image(systemName: "globe")
    }
}

#Preview {
    let project = PersistenceController.preview.fetchAllProjects().first!
    let binding: Binding<ProjectEntity> = .constant(project)
    return MenuTileView(project: binding) { _ in }
        .scaledToFit()
}

#Preview {
    let vm = MenuViewModel()
    vm.projects = PersistenceController.preview.fetchAllProjects()
    return MenuScrollView { _ in }.environmentObject(vm)
}

#Preview {
    UpperMenuView()
}

#Preview {
    MenuView()
}
