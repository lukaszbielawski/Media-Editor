//
//  AddProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Kingfisher
import Photos
import SwiftUI

struct AddProjectView: View {
    @StateObject var vm = AddProjectViewModel()

    var body: some View {
        Text("Choose media to your project")
            .padding()
            .font(.title2)
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                AddProjectGridView()
            }
            AddProjectSummaryView()
        }
        .environmentObject(vm)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct AddProjectGridView: View {
    @EnvironmentObject var vm: AddProjectViewModel

    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 4), count: UIDevice.current.userInterfaceIdiom == .phone ? 3 : 5)

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(vm.media, id: \.localIdentifier) { media in
                    ZStack {
                        AddProjectGridTileView(media: media)
                    }
                }
            }
        }
        .padding(4)
    }
}

extension UIScreen {
    static var bottomSafeArea: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }.first

        return (keyWindow?.safeAreaInsets.bottom) ?? 0
    }
}

struct AddProjectGridTileView: View {
    @State var thumbnail: UIImage?
    @EnvironmentObject var vm: AddProjectViewModel
    @State var isSelected: Bool = false

    @State var media: PHAsset
    var body: some View {
        ZStack {
            ZStack {
                Group {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .centerCropped()

                    } else {
                        Color(.primary)
                    }
                }.aspectRatio(1.0, contentMode: .fill)
                    .cornerRadius(4.0)

            }.overlay {
                if isSelected {
                    ZStack(alignment: .topLeading) {
                        Color(.primary)
                            .opacity(isSelected ? 0.7 : 0)
                            .aspectRatio(1.0, contentMode: .fill)
                            .cornerRadius(4.0)
                        Circle()
                            .fill(Color(.primary))
                            .frame(width: 25, height: 25)
                            .padding(4.0)
                            .overlay {
                                Text("\((vm.selectedAssets.firstIndex(of: media) ?? 0) + 1)")
                            }
                    }
                } else if media.mediaType == .video {
                    ZStack(alignment: .bottomTrailing) {
                        Color(.primary)
                            .opacity(isSelected ? 0.7 : 0)
                            .aspectRatio(1.0, contentMode: .fill)
                            .cornerRadius(4.0)

                        HStack {
                            Spacer()
                                .frame(maxWidth: .infinity)
                            Capsule()
                                .fill(Color(.primary))
                                .frame(height: 25)
                                .padding(4.0)
                                .overlay {
                                    Text("\(media.formattedDuration)")
                                }
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .onTapGesture {
            HapticService.shared.play(.light)
            isSelected = vm.toggleMediaSelection(for: media)
        }
        .task {
            thumbnail = try? await vm.fetchPhoto(for: media, desiredSize:
                .init(width: UIScreen.main.nativeBounds.width * (UIDevice.current.userInterfaceIdiom == .phone ? 0.33 : 0.2),
                      height: UIScreen.main.nativeBounds.width * (UIDevice.current.userInterfaceIdiom == .phone ? 0.33 : 0.2)))

        }.onDisappear {
            thumbnail = nil
        }
    }
}

struct AddProjectSummaryView: View {
    @EnvironmentObject var vm: AddProjectViewModel
    var totalHeight: Double { 100.0 + UIScreen.bottomSafeArea }
    var body: some View {
        ZStack {
//            Color(.primary)
            Rectangle()
                .fill(Material.thickMaterial)
                .frame(height: totalHeight)
                .roundedUpperCorners(16)
            AddProjectSummarySliderView()
                .padding(.bottom, UIScreen.bottomSafeArea)
        }
        .animation(.spring(), value: vm.projectType)
        .offset(y: vm.projectType == .unknown ? totalHeight : 0)
    }
}

struct AddProjectSummarySliderView: View {
    @EnvironmentObject var vm: AddProjectViewModel

    @State var sliderOffset: Double = 0.0
    @State var sliderWidth: Double = 0.0
    @State var isInteractive: Bool = true
    @State var alreadySwiped: Bool = false
  

    var maxOffset: Double { return sliderWidth - sliderHeight }
    let sliderHeight = 50.0

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .circular)
                .fill(Color(vm.projectType == .movie ? .accent : .accent2))
                .overlay(Material.ultraThinMaterial)
                .clipShape(Capsule(style: .circular))
                .frame(maxWidth: 300, maxHeight: sliderHeight)

                .overlay {
                    Label("Create a \(vm.projectType == .movie ? "movie" : "photo") project", systemImage: "chevron.right.2")
                        .padding(.leading, 16)
                }
                .overlay {
                    GeometryReader { geo in
                        Color.clear
                            .task {
                                sliderWidth = geo.size.width
                            }
                    }
                }
            Capsule(style: .circular)
                .fill(Color(vm.projectType == .movie ? .accent : .accent2))
                .frame(width: sliderHeight + sliderOffset, height: sliderHeight)
            Circle()
                .fill(Color.white)
                .frame(width: sliderHeight, height: sliderHeight)
                .overlay {
                    Image(systemName: vm.projectType == .movie ? "film" : "photo")
                        .foregroundStyle(Color(vm.projectType == .movie ? .accent : .accent2))
                }
                .offset(x: sliderOffset)
                .allowsHitTesting(isInteractive)
                .preference(key: ProjectCreatedPreferenceKey.self, value: vm.createdProject)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !alreadySwiped else { return }

                            sliderOffset = min(max(value.translation.width, 0.0), maxOffset)
                            if sliderOffset > sliderWidth * 0.5 {
                                    
                                DispatchQueue.main.async {
                                    alreadySwiped = true
                                    isInteractive = false
                                    HapticService.shared.notify(.success)
                                    
                                    let animationDuration = (maxOffset - sliderOffset) / maxOffset
                                    
                                    withAnimation(Animation.easeOut(duration: animationDuration)) {
                                        sliderOffset = maxOffset
                                    }
                                } 
                                
                                Task { try await vm.runCreateProjectTask() }
                            }
                        }
                        .onEnded { _ in
                            if !alreadySwiped {
                                withAnimation(Animation.easeOut(duration: sliderOffset / maxOffset)) {
                                    sliderOffset = 0.0
                                }
                            }
                        }
                )
        }
        .frame(maxWidth: 300)
        .padding(.horizontal, 50)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .primary)
//        AddProjectSummarySliderView(isNavigationActive: .constant(false))
//            .environmentObject(AddProjectViewModel())
    }
}

// #Preview {
//    AddProjectView(isNavigationActive: .constant(false))
// }
