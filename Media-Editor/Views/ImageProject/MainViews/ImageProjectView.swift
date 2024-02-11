//
//  ImageProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import SwiftUI

struct ImageProjectView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var vm: ImageProjectViewModel
    
    init(project: ImageProjectEntity?) {
        _vm = StateObject(wrappedValue: ImageProjectViewModel(project: project!))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ImageProjectPlaneView()

                ImageProjectToolScrollView()
            }
            .background(Color(.primary))
            .background {
                NavBarAccessor { navBar in
                    vm.plane.totalNavBarHeight = navBar.bounds.height + UIScreen.topSafeArea
                }
            }
            .navigationBarBackButtonHidden(true)
            .modifier(StatusBarHiddenModifier())
            .ignoresSafeArea(edges: .top)
            .onAppear {
                vm.plane.totalLowerToolbarHeight = vm.plane.lowerToolbarHeight + UIScreen.bottomSafeArea
            }

            .toolbar {
                ImageProjectViewToolbar()
            }
        }   .environmentObject(vm)
    }
}
