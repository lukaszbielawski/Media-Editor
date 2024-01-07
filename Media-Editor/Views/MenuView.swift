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
    @Environment(\.managedObjectContext) private var context
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
                    .environment(\.managedObjectContext, context)
                    .gesture(DragGesture().onEnded { value in
                        if value.translation.height > 50 {
                            isManageProjectSheetPresented = false
                        }
                    })
            }
        }
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
    return TileView(project: binding) { _ in }
        .scaledToFit()
}

#Preview {
    var vm = MenuViewModel()
    vm.projects = PersistenceController.preview.fetchAllProjects()
    return MenuScrollView { _ in }.environmentObject(vm)
}

#Preview {
    UpperMenuView()
}

#Preview {
    MenuView()
}
