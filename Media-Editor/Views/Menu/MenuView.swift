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
    @StateObject var vm = MenuViewModel()

    @State var createdProjectType: ProjectType = .unknown
    @State var isManageProjectSheetPresented: Bool = false

    @State var performTransition = false {
        didSet {
            if oldValue == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    performTransition = false
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                MenuScrollView { id in
                    let project = PersistenceController.shared.projectController.fetch(for: id)
                    vm.selectedProject = project
                    isManageProjectSheetPresented = true
                }
                .ignoresSafeArea(.keyboard)
                .environmentObject(vm)

                MenuManageProjectSheetView(isManageProjectSheetPresented: $isManageProjectSheetPresented)
                    .environmentObject(vm)
                    .gesture(DragGesture().onEnded { value in
                        if value.translation.height > 50 {
                            isManageProjectSheetPresented = false
                        }
                    })
            }.navigationBarHidden(true)
        }
        .onPreferenceChange(ProjectCreatedPreferenceKey.self) { value in
            guard let value else { return }
            createdProjectType = value.isMovie ? .movie : .photo
            performTransition = true
        }
        .navigationViewStyle(.stack)

        .overlay {
            Color(createdProjectType == .movie ? .accent : .accent2)
                .ignoresSafeArea()
                .opacity(performTransition ? 1.0 : 0.0)
                .animation(.easeOut(duration: 1.0), value: performTransition)
        }
    }
}

#Preview {
    MenuView()
}
