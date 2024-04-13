//
//  ImageProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Combine
import SwiftUI

struct ImageProjectView: View {
    @StateObject var vm: ImageProjectViewModel

    @Environment(\.dismiss) var dismiss

    @State var isEditingFrameVisible = false
    @State var editingFrameOpacity: CGFloat = 1.0
    @State private var isToastShown = (isShown: false, result: false)

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

                    Group {
                        if let currentTool = vm.currentTool as? ProjectToolType, currentTool == .merge {
                            ForEach(vm.layersToMerge) { layerModel in
                                ImageProjectMergingFrameView(layerModel: layerModel)
                            }
                        } else if let layerModel = vm.activeLayer, let positionZ = layerModel.positionZ, positionZ > 0 {
                            ImageProjectEditingFrameView(layerModel: layerModel)
                        }
                    }.transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                        .zIndex(Double(Int.max) - 2)

                    Path { path in
                        let points = vm.calculatePathPoints()
                        guard let planeScale = vm.plane.scale,
                              let workspaceSize = vm.workspaceSize else { return }
                        if let xPoints = points.xPoints {
                            path.move(to: CGPoint(x: xPoints.startPoint.x * planeScale
                                    - workspaceSize.width * 0.5 * (planeScale - 1.0),
                                y: 0))
                            path.addLine(to: CGPoint(x: xPoints.endPoint.x * planeScale
                                    - workspaceSize.width * 0.5 * (planeScale - 1.0),
                                y: workspaceSize.height))
                        }
                        if let yPoints = points.yPoints {
                            path.move(to: CGPoint(x: 0,
                                                  y: yPoints.startPoint.y * planeScale
                                                      - workspaceSize.height * 0.5 * (planeScale - 1.0)))
                            path.addLine(to: CGPoint(x: workspaceSize.width,
                                                     y: yPoints.endPoint.y * planeScale
                                                         - workspaceSize.height * 0.5 * (planeScale - 1.0)))
                        }
                    }
                    .stroke(Color(.accent), lineWidth: 1)
                    .allowsHitTesting(false)

                    if let currentTool = vm.currentTool as? LayerToolType,
                       currentTool == .crop || currentTool == .background
                    {
                        ImageProjectFocusView()
                            .zIndex(Double(Int.max) - 1)
                            .transition(AnyTransition
                                .scale(scale: 0.0, anchor: UnitPoint(x: 1, y: 0.5))
                                .animation(.easeInOut(duration: 0.35)))
                    }
                }
                .onChange(of: vm.activeLayer) { _ in
                    vm.plane.lineXPosition = nil
                    vm.plane.lineYPosition = nil
                }

                ImageProjectToolView()
                    .zIndex(Double(Int.max) + 1)
            }
            .overlay {
                if isToastShown.isShown {
                    let systemName =
                        isToastShown.result ? "checkmark.seal.fill" : "xmark.seal.fill"
                    ImageProjectToastView(systemName: systemName)
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                }
            }
            .onReceive(vm.showImageExportResultToast) { result in
                isToastShown = (true, result)

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    isToastShown = (false, result)
                }
            }
            .background(Color(.primary))
            .background {
                NavBarAccessor { navBar in
                    DispatchQueue.main.async {
                        vm.plane.totalNavBarHeight = navBar.bounds.height + UIScreen.topSafeArea
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .modifier(StatusBarHiddenModifier())
            .ignoresSafeArea(edges: .top)
            .onAppear {
                vm.plane.totalLowerToolbarHeight = vm.plane.lowerToolbarHeight + UIScreen.bottomSafeArea
            }
            .toolbar { imageProjectToolbar }
            .sheet(isPresented: $vm.isExportSheetPresented) {
                ImageProjectExportPhotosView()
                    .background {
                        Image("MenuBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    }
            }
            .alert("Deleting image", isPresented: $vm.tools.isDeleteImageAlertPresented) {
                Button("Cancel", role: .cancel) {
                    vm.tools.isDeleteImageAlertPresented = false
                    vm.layerToDelete = nil
                }

                Button("Confirm", role: .destructive) {
                    vm.tools.isDeleteImageAlertPresented = false
                    if vm.activeLayer == vm.layerToDelete {
                        vm.deactivateLayer()
                    }
                    vm.deleteLayer()
                }
            } message: {
                Text("Are you sure you want to remove this image from the project?")
            }

        }.environmentObject(vm)
            .transition(AnyTransition.slide.animation(.easeInOut(duration: 1.0)))
    }
}
