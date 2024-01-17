//
//  ImageProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import SwiftUI

struct ImageProjectView: View {
    @StateObject var vm: ImageProjectViewModel

    init(project: ImageProjectEntity?) {
        _vm = StateObject(wrappedValue: ImageProjectViewModel(project: project!))

        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(Color(.primary))
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.tint]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.tint]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    let lowerToolbarHeight = 100.0

    var body: some View {
        ZStack {
            Color(.background)
                .zIndex(Double(Int.min))
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ImageProjectPlaneView()
                Color.mint
                    .frame(height: lowerToolbarHeight)
            }
            .environmentObject(vm)
        }     .ignoresSafeArea()
    }
}

struct ImageProjectPlaneView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var scale = 1.0
    @State var lastScaleValue = 1.0
    let minScale = 1.0
    let maxScale = 5.0
    @State var geoProxy: GeometryProxy?
    @State var dragged = false

    @State var position = CGPoint()
    @GestureState private var fingerPosition: CGPoint? = nil
    @GestureState private var startPosition: CGPoint? = nil

    var body: some View {
        ZStack {
            Color.clear
                .zIndex(Double(Int.min + 1))
                .overlay {
                    GeometryReader { geo in

                        Color.clear

                            .onAppear {
                                geoProxy = geo
                                    position = CGPoint(x: geo.frame(in: .global).width / 2, y: geo.frame(in: .global).height / 2)

                                print(geo.frame(in: .global).midX, geo.frame(in: .global).midY)
                                print(geo.safeAreaInsets)
                            }
                    }
                }

            ImageProjectFrameView(geo: geoProxy)
                .zIndex(Double(Int.min + 2))
//                ForEach(vm.media) { image in
//                    if image.positionZ != nil {
//                        ImageProjectLayerView(image: image)
//                    }
//                }
        }
   
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    var newPosition = startPosition ?? position
                    newPosition.x += value.translation.width
                    newPosition.y += value.translation.height
                    dragged = true
                    position = newPosition
                }
                .updating($startPosition) { _, startPosition, _ in
                    startPosition = startPosition ?? position
                }
        )
        .scaleEffect(scale)
        .animation(.linear(duration: 0.2), value: scale)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScaleValue
                    scale *= delta
                    lastScaleValue = value
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

    private let padding: CGFloat = 0.05

    var geo: GeometryProxy?
    var body: some View {
        if let geo {
            ZStack {
                Image("alpha_pattern")
                    .resizable(resizingMode: .tile)
                    .frame(width: frameWidth, height: frameHeight)
                    .shadow(radius: 10.0)
                    .onAppear {
                        let (width, height) = vm.project.getFrame()
                        let (geoWidth, geoHeight) = (geo.size.height * (1 - 2 * padding), geo.size.width * (1 - 2 * padding))
                        let aspectRatio = height / width
                        let geoAspectRatio = geoWidth / geoHeight

                        if aspectRatio < geoAspectRatio {
                            frameWidth = geoWidth
                            frameHeight = geoWidth * aspectRatio
                        } else {
                            frameHeight = geoHeight
                            frameWidth = geoHeight / aspectRatio
                        }
                    }
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

// #Preview {
//    ImageProjectLayerView()
// }
//
// #Preview {
//    ImageProjectPlaneView()
// }
