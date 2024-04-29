//
//  ProjectToolTileSelectedModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

struct ProjectToolTileSelectedModifier: ViewModifier {
    let paddingFactor: CGFloat
    let lowerToolbarHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: paddingFactor * lowerToolbarHeight)
                    .fill(Color.white)
                    .padding(2.0)
                    .blendMode(.destinationOut)
            )
            .compositingGroup()
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}
