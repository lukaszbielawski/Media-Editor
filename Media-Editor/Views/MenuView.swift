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
        ZStack {
            GeometryReader { geo in
                VStack {
                    UpperMenuView()
                        .frame(height: geo.size.height * 2 / 5)
                    MenuScrollView(projects: $vm.projects) { id in
                        if let index = vm.findIndexForUUID(uuid: id) {
                            vm.selectedProject = vm.projects[index]
                            isManageProjectSheetPresented = true
                        }
                    }
                }
            }
            ManageProjectSheet(isManageProjectSheetPresented: $isManageProjectSheetPresented, vm: vm)
                .gesture(DragGesture().onEnded { value in
                    if value.translation.height > 50 {
                        isManageProjectSheetPresented = false
                    }
                })
        }
    }
}

struct UpperMenuView: View {
    var body: some View {
        Image(systemName: "globe")
    }
}

struct ManageProjectSheet: View {
    @Binding var isManageProjectSheetPresented: Bool
    @State var isAlertPresented: Bool = false
    @ObservedObject var vm: MenuViewModel

    @State var projectName: String = ""

    var body: some View {
        ZStack {
            Color.gray.opacity(isManageProjectSheetPresented ? 0.7 : 0.0)
                .animation(.spring())
                .ignoresSafeArea()
                .onTapGesture {
                    isManageProjectSheetPresented = false
                }
                .allowsHitTesting(isManageProjectSheetPresented)
            GeometryReader { geometry in
                VStack {
                    Spacer()

                    VStack(spacing: 16) {
                        Spacer()
                        Text("Change project name")
                            .foregroundStyle(Color.tint)
                        HStack {
                            Spacer()
                            TextField("Project name", text: $projectName)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 32)
                                .onChange(of: vm.selectedProject) { _ in
                                    projectName = vm.selectedProject?.title ?? "nil"
                                }
                            Spacer()
                        }

                        Button("Back", role: .cancel) {
                            isManageProjectSheetPresented = false
                            vm.selectedProject?.title = projectName
                            DispatchQueue.main.async {
                                PersistenceController.shared.saveContext()
                            }
                        }.buttonStyle(.borderedProminent)

                        Spacer()
                        Button(role: .destructive, action: {
                            isAlertPresented = true
                        }, label: {
                            Label("Delete project", systemImage: "trash")
                        })
                        .padding(.bottom)
                        .buttonStyle(.borderedProminent)
                        .alert("Are you sure you want to delete \(vm.selectedProject?.title ?? "nil")?", isPresented: $isAlertPresented) {
                            Button("Go back", role: .cancel) {
                                isAlertPresented = false
                            }
                            Button("Confirm", role: .destructive) {
                                vm.projects.removeAll(where: { $0.id == vm.selectedProject?.id} )
                                DispatchQueue.main.async {
                                    PersistenceController.shared.deleteObject(object: vm.selectedProject)
                                    PersistenceController.shared.saveContext()
                                }
                                isAlertPresented = false
                                isManageProjectSheetPresented = false
                            }
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    .background(Color(.primary))
                    .cornerRadius(10)
                    .offset(y: isManageProjectSheetPresented ? 0 : geometry.size.height / 2)
                    .animation(.spring())
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
    let project = PersistenceController.shared.preview.first!
    let binding: Binding<ProjectEntity> = .constant(project)
    return TileView(project: binding) { _ in }
        .scaledToFit()
}

#Preview {
    let preview = PersistenceController.shared.preview
    let bindingArray: Binding<[ProjectEntity]> = .constant(preview)
    return MenuScrollView(projects: bindingArray) { _ in }
}

#Preview {
    UpperMenuView()
}

#Preview {
    MenuView()
}
