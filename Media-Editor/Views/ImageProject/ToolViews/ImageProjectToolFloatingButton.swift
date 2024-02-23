//
//  ImageProjectToolFloatingButton.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import SwiftUI

struct ImageProjectToolFloatingButtonView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var color: ColorResource = .image
    var systemName: String = "arrow.uturn.backward"
    var action: (() -> Void)?

    var body: some View {
        ZStack {
            Circle().fill(Color(color))

            Button(action: {
                DispatchQueue.main.async {
                    action?()
                }
            }, label: {
                Image(systemName: systemName)
                    .foregroundStyle(Color(.tint))
                    .contentShape(Rectangle())
                    .font(.title)
            })
        }
        .frame(width: vm.plane.lowerToolbarHeight * 0.5,
               height: vm.plane.lowerToolbarHeight * 0.5)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))

    }
}
