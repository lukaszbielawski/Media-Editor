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

    let lowerToolbarHeight = 100.0

    var body: some View {
        VStack(spacing: 0) {
            ImageProjectPlaneView(totalNavBarHeight: $totalNavBarHeight,
                                  totalLowerToolbarHeight: $totalLowerToolbarHeight)
            Color.accentColor
                .frame(height: lowerToolbarHeight)
        }
        .background {
            NavBarAccessor { navBar in
                totalNavBarHeight = navBar.bounds.height + UIScreen.topSafeArea
            }
        }.onAppear {
            totalLowerToolbarHeight = lowerToolbarHeight + UIScreen.bottomSafeArea
        }
        .navigationBarBackButtonHidden(true)
        .environmentObject(vm)
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
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
        }
    }
}

struct ImageProjectPlaneView: View {
    @EnvironmentObject private var vm: ImageProjectViewModel

    @State private var scale = 1.0
    @State private var lastScaleValue = 1.0
    @State private var geoProxy: GeometryProxy?
    @State private var frameViewRect: CGRect?
    @State private var planeSize = CGSize()
    @State private var position = CGPoint()
    @State private var furthestPlanePointAllowed: CGPoint?

    @GestureState private var lastPosition: CGPoint?

    @Binding var totalNavBarHeight: Double?
    @Binding var totalLowerToolbarHeight: Double?

    let minScale = 1.0
    let maxScale = 10.0
    let previewMinScale = 0.2
    let previewMaxScale = 20.0

    let frameViewPadding = 16

    var body: some View {
        ZStack {
            Color.clear
                .frame(minWidth: planeSize.width,
                       maxWidth: .infinity,
                       minHeight: planeSize.height,
                       maxHeight: .infinity)

                .contentShape(Rectangle())
                .zIndex(Double(Int.min + 1))
                .geometryAccesor { geo in
                    DispatchQueue.main.async {
                        guard let totalLowerToolbarHeight else { return }
                        print(geo.size)
                        geoProxy = geo
                        position = CGPoint(x: geo.size.width / 2, y: (geo.size.height) / 2)

                        furthestPlanePointAllowed =
                            CGPoint(x: geo.size.width,
                                    y: geo.size.height + totalLowerToolbarHeight)
                    }
                }
            ImageProjectFrameView(totalLowerToolbarHeight: $totalLowerToolbarHeight, geo: geoProxy)
                .zIndex(Double(Int.min + 2))
                .overlay {
                    Color.clear
                        .border(Color.green)
                        .padding(16)
                }
        }
        .border(Color.blue)
        .position(position)
        .onPreferenceChange(ImageProjectFramePreferenceKey.self) { frameViewRect in
            guard let frameViewRect, let geoProxy else { return }
            self.frameViewRect = frameViewRect
            planeSize =
                CGSize(width: frameViewRect.width + geoProxy.size.width * 2.0,
                       height: frameViewRect.height + geoProxy.size.height * 2.0)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    var newPosition = lastPosition ?? position
                    newPosition.x += value.translation.width
                    newPosition.y += value.translation.height

                    position = {
                        guard let furthestPlanePointAllowed,
                              let frameViewRect,
                              let totalNavBarHeight,
                              let totalLowerToolbarHeight
                        else {
                            return newPosition
                        }

                        let (newX, newY) = (newPosition.x, newPosition.y)
                        let (maxX, maxY) =
                            (furthestPlanePointAllowed.x.intFloor + frameViewRect.width.intFloor / 2,
                             furthestPlanePointAllowed.y.intFloor -
                                 totalLowerToolbarHeight.intFloor + frameViewRect.height.intFloor / 2)
                        print(totalNavBarHeight.intFloor)
                        let (minX, minY) =
                            (-frameViewRect.width.intFloor / 2,
                             -frameViewRect.height.intFloor / 2 + totalNavBarHeight.intFloor)

                        if (minX + frameViewPadding...maxX -
                            frameViewPadding).contains(newX.intFloor),
                            (minY + frameViewPadding...maxY - frameViewPadding).contains(newY.intFloor)
                        {
                            return newPosition
                        } else {
                            return position
                        }

                    }() as CGPoint
                    print(position, UIScreen.topSafeArea.intFloor)
                }
                .updating($lastPosition) { _, startPosition, _ in
                    startPosition = startPosition ?? position
                }
        )
        .scaleEffect(scale)
        .animation(.linear(duration: 0.2), value: scale)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    DispatchQueue.main.async {
                        let delta = value / lastScaleValue
                        scale = min(max(scale * delta, previewMinScale), previewMaxScale)
                        lastScaleValue = value
                    }
                }
                .onEnded { _ in
                    if scale > maxScale {
                        scale = min(maxScale, scale)
                    } else {
                        scale = max(minScale, scale)
                    }

                    lastScaleValue = 1.0
                }
        )
    }
}

struct ImageProjectFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var frameWidth: CGFloat = 0.0
    @State var frameHeight: CGFloat = 0.0
    @State var orientation: Image.Orientation = .up

    @State var frameViewRect: CGRect?

    private let framePaddingFactor: CGFloat = 0.05
    @Binding var totalLowerToolbarHeight: Double?

    var geo: GeometryProxy?
    var body: some View {
        if let geo {
            ZStack {
                Image("AlphaVector")
                    .resizable(resizingMode: .tile)
                    .frame(width: frameWidth, height: frameHeight)
                    .shadow(radius: 10.0)
                    .onAppear {
                        guard let totalLowerToolbarHeight else { return }

                        let (width, height) = vm.project.getFrame()
                        let (geoWidth, geoHeight) =
                            (geo.size.width * (1.0 - 2 * framePaddingFactor),
                             (geo.size.height - totalLowerToolbarHeight) * (1.0 - 2 * framePaddingFactor))
                        let aspectRatio = height / width
                        let geoAspectRatio = geoHeight / geoWidth

                        if aspectRatio < geoAspectRatio {
                            frameWidth = geoWidth
                            frameHeight = geoWidth * aspectRatio
                        } else {
                            frameHeight = geoHeight
                            frameWidth = geoHeight / aspectRatio
                        }

                        let centerPoint =
                            CGPoint(x: geo.frame(in: .global).midX,
                                    y: geo.frame(in: .global).midY - totalLowerToolbarHeight * 0.5)

                        let topLeftCorner =
                            CGPoint(x: centerPoint.x - frameWidth * 0.5,
                                    y: centerPoint.y - frameHeight * 0.5)

                        frameViewRect =
                            CGRect(origin: topLeftCorner,
                                   size: CGSize(width: frameWidth, height: frameHeight))
                    }
                    .preference(key: ImageProjectFramePreferenceKey.self, value: frameViewRect)
            }
        }
    }
}

struct ImageProjectLayerView: View {
    var image: PhotoModel
    var body: some View {
        Image(decorative: image.cgImage, scale: 1.0, orientation: .up)
//                    .resizable()
//                    .frame(width: frameWidth, height: frameHeight)
//                    .position(x: frameWidth / 2, y: frameHeight / 2)
//                    .zIndex(Double(positionZ))
    }
}
