//
//  ManageProjectSheetView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import SwiftUI

struct ManageProjectSheetView: View {
    @Binding var isManageProjectSheetPresented: Bool
    @State var isAlertPresented: Bool = false
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var vm: MenuViewModel

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
                            vm.updateUIAndSaveChanges(context: context)

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
                                vm.deleteProject(vm.selectedProject!)
                                vm.updateUIAndSaveChanges(context: context)
                                
                                isAlertPresented = false
                                isManageProjectSheetPresented = false
                            }
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height / 2)
                    .background(Color(.primary))
                    .roundedUpperCorners(16)
                    .offset(y: isManageProjectSheetPresented ? 0 : geometry.size.height / 2)
                    .animation(.spring())
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
