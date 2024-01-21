//
//  ImageProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import SwiftUI

struct ImageProjectView: View {
    @StateObject var vm: ImageProjectViewModel
    @Environment(\.dismiss) var dismiss

    init(project: ImageProjectEntity?) {
        _vm = StateObject(wrappedValue: ImageProjectViewModel(project: project!))

        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color(.accent))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.tint]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.tint]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    @State var totalLowerToolbarHeight: Double?
    @State var isSaved: Bool = false
    @State var totalNavBarHeight: Double?
    @State var isArrowActive = (undo: true, redo: false)
    @State var centerButtonFunction: (() -> Void)?

    let lowerToolbarHeight = 100.0

    var body: some View {
        VStack(spacing: 0) {
            ImageProjectPlaneView(totalNavBarHeight: $totalNavBarHeight,
                                  totalLowerToolbarHeight: $totalLowerToolbarHeight,
                                  centerButtonTapped: $centerButtonFunction)
            ImageProjectToolsScrollView(lowerToolbarHeight: lowerToolbarHeight)
        }
        .background(Color(.primary))
        .background {
            NavBarAccessor { navBar in
                totalNavBarHeight = navBar.bounds.height + UIScreen.topSafeArea
            }
        }.onAppear {
            totalLowerToolbarHeight = lowerToolbarHeight + UIScreen.bottomSafeArea
        }

        .navigationBarBackButtonHidden(true)
        .statusBarHidden()
        .environmentObject(vm)
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Label(isSaved ? "Back" : "Save", systemImage: isSaved ? "chevron.left" : "square.and.arrow.down")
                    .labelStyle(.titleAndIcon)
                    .onTapGesture {
                        if isSaved {
                            dismiss()
                        } else {
                            // TODO: save action
                            isSaved = true
                        }
                    }
                    .foregroundStyle(Color.white)
            }
            ToolbarItemGroup(placement: .principal) {
                HStack {
                    Group {
                        Spacer().frame(width: 11)
                        Label("Undo", systemImage: "arrowshape.turn.up.backward.fill")
                            .opacity(isArrowActive.undo ? 1.0 : 0.5)
                            .onTapGesture { print("undo") }
                        Label("Redo", systemImage: "arrowshape.turn.up.forward.fill")
                            .opacity(isArrowActive.redo ? 1.0 : 0.5)
                            .onTapGesture { print("redo") }
                        Spacer().frame(width: 22)
                        Label("Center", systemImage: "camera.metering.center.weighted")
                            .onTapGesture {
                                guard let centerButtonFunction else { return }
                                centerButtonFunction()
                            }
                    }
                    .foregroundStyle(Color.white)
                }.frame(maxWidth: .infinity)
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Label("Export", systemImage: "square.and.arrow.up.on.square.fill")
                    .labelStyle(.titleAndIcon)
                    .onTapGesture {}
                    .foregroundStyle(Color.white)
            }
        }
    }
}
