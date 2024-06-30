//
//  OnboardingTabVideoView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 30/06/2024.
//

import SwiftUI

struct OnboardingTabVideoView: View {
    @EnvironmentObject var vm: OnboardingViewModel

    let videoName: String
    let videoExtension: String
    let labelText: String

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack(alignment: .bottom) {
                    VideoPlayerView(fileName: videoName, fileType: videoExtension)
                        .frame(height: geo.size.height * 0.75)
                        .ignoresSafeArea()
                    LinearGradient(colors: [Color.clear, Color.white], startPoint: UnitPoint(x: 0.5, y: 0.0), endPoint: UnitPoint(x: 0.5, y: 1.0))
                        .frame(height: geo.size.height * 0.25)
                        .ignoresSafeArea()
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                Text(labelText)
                    .font(.init(.custom("Kaushan Script", size: 32)))
                    .padding(16.0)
            }
        }
        .ignoresSafeArea()
    }
}
