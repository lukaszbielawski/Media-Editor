//
//  MenuManageProjectSheetView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import SwiftUI

struct MenuManageProjectSheetView: View {
    @Binding var isManageProjectSheetPresented: Bool
    @State var isAlertPresented: Bool = false
    @FocusState private var isFocused: Bool
    @EnvironmentObject var vm: MenuViewModel

    @State var sheetHeight: Double = 0.0
    @State var projectName: String = ""

    var body: some View {
        ZStack {
            Color.gray
                .opacity(isManageProjectSheetPresented ? 0.7 : 0.0)
                .animation(.spring(), value: isManageProjectSheetPresented)
                .ignoresSafeArea()
                .onTapGesture {
                    isManageProjectSheetPresented = false
                }
                .allowsHitTesting(isManageProjectSheetPresented)
            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 16) {
                        Spacer()
                        Text("Change project name")
                            .foregroundStyle(Color.tint)
                        HStack {
                            Spacer()
                            TextField("Project name", text: $projectName)
                                .focused($isFocused)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 32)
                                .onChange(of: vm.selectedProject) { _ in
                                    projectName = vm.selectedProject?.title ?? "nil"
                                }
                            Spacer()
                        }

                        Button("Back", role: .cancel) {
                            isManageProjectSheetPresented = false
                            HapticService.shared.play(.light)
                        }.buttonStyle(.borderedProminent)

                        Spacer()
                            .frame(maxHeight: .infinity)
                        Button(role: .destructive, action: {
                            isAlertPresented = true
                            HapticService.shared.notify(.warning)
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
                                isAlertPresented = false
                                isManageProjectSheetPresented = false
                                HapticService.shared.play(.medium)
                            }
                        }
                        Spacer()
                            .frame(maxHeight: .infinity)
                    }
                    .background(Color(.primary).ignoresSafeArea())
                    .roundedUpperCorners(16)
                    .task {
                        sheetHeight = geo.size.height
                    }

                    .animation(vm.keyboardAnimation ?? .spring(duration: 100.0), value: vm.keyboardHeight)
                    .frame(width: geo.size.width, height: sheetHeight / 2 + vm.keyboardHeight)
                    .animation(.spring(), value: isManageProjectSheetPresented) ///
                    .offset(y: isManageProjectSheetPresented ? vm.keyboardHeight : sheetHeight / 2)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onChange(of: isManageProjectSheetPresented) { isPresented in
            if !isPresented {
                isFocused = false
                vm.updateProjectTitle(title: projectName)
            }
        }
        .onTapGesture {
            isFocused = false
        }
    }
}
