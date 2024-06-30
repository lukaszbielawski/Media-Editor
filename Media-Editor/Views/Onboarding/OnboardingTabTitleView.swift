//
//  OnboardingTabTitleView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import SwiftUI

struct OnboardingTabTitleView: View {
    @State var swipeToStartLabelOpacity = 1.0

    var body: some View {
        VStack {
            Spacer()
            Text("Pixiva")
                .font(.init(.custom("Kaushan Script", size: 144)))
            Text("Let your imagination run wild")
                .font(.init(.custom("Kaushan Script", size: 32)))
            Spacer()
            Label("Swipe right to start", systemImage: "chevron.forward.2")
                .font(.title2)
                .opacity(swipeToStartLabelOpacity)
                .labelStyle(RightSideIconLabelStyle())
            Spacer()
        }
        .foregroundStyle(Color(.tint))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                swipeToStartLabelOpacity = 0.3
            }
        }
    }
}
