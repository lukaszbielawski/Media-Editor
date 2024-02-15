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

    @State var isSaved: Bool = false
    @State var isArrowActive = (undo: true, redo: false)
    @State var isEditingFrameVisible = false
    @State var editingFrameOpacity: CGFloat = 1.0

    init(project: ImageProjectEntity?) {
        _vm = StateObject(wrappedValue: ImageProjectViewModel(projectEntity: project!))

        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color(.image))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.tint]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.tint]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    ImageProjectPlaneView()

                    if let layerModel = vm.activeLayer, let positionZ = layerModel.positionZ, positionZ > 0 {
                        ImageProjectEditingFrameView(layerModel: layerModel)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                            .zIndex(Double(Int.max) - 2)
                    }

                    Path { path in
                        let points = vm.calculatePathPoints()
                        if let xPoints = points.xPoints {
                            path.move(to: CGPoint(x: xPoints.startPoint.x * (vm.plane.scale ?? 1.0),
                                                  y: xPoints.startPoint.y * (vm.plane.scale ?? 1.0)))
                            path.addLine(to: CGPoint(x: xPoints.endPoint.x * (vm.plane.scale ?? 1.0),
                                                     y: xPoints.endPoint.y * (vm.plane.scale ?? 1.0)))
                        }
                        if let yPoints = points.yPoints {
                            path.move(to: CGPoint(x: yPoints.startPoint.x * (vm.plane.scale ?? 1.0),
                                                  y: yPoints.startPoint.y * (vm.plane.scale ?? 1.0)))
                            path.addLine(to: CGPoint(x: yPoints.endPoint.x * (vm.plane.scale ?? 1.0),
                                                     y: yPoints.endPoint.y * (vm.plane.scale ?? 1.0)))
                        }
                    }
                    .stroke(Color(.movie), lineWidth: 1)
                    .allowsHitTesting(false)
                }
                .onChange(of: vm.activeLayer) { _ in
                    vm.plane.lineXPosition = nil
                    vm.plane.lineYPosition = nil
                }

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
            .toolbar { imageProjectToolbar }
            .alert("Deleting image", isPresented: $vm.tools.isDeleteImageAlertPresented) {
                Button("Cancel", role: .cancel) {
                    vm.tools.isDeleteImageAlertPresented = false
                    vm.layerToDelete = nil
                }

                Button("Confirm", role: .destructive) {
                    vm.tools.isDeleteImageAlertPresented = false
                    if vm.activeLayer == vm.layerToDelete {
                        vm.activeLayer = nil
                    }
                    vm.deleteLayer()
                }
            } message: {
                Text("Are you sure you want to remove this image from the project?")
            }

        }.environmentObject(vm)
    }
}
