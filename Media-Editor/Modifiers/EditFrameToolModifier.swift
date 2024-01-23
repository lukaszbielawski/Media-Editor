//
//  EditFrameToolModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/01/2024.
//

import Foundation
import SwiftUI

struct EditFrameToolModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat

//    let buttonOffset = 24.0

    func body(content: Content) -> some View {
        RoundedRectangle(cornerRadius: 2.0)
            .fill(Color(.image))
            .padding(14)
            .frame(width: width + 38, height: height + 38)

            .overlay {
                content
            }
            .overlay(alignment: .topLeading) {
                Image(systemName: "trash")
                    .modifier(EditFrameCircleModifier())
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "crop.rotate")
                    .modifier(EditFrameCircleModifier())
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .modifier(EditFrameCircleModifier())
            }
            .overlay(alignment: .bottomLeading) {
                Image(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill")
                    .modifier(EditFrameCircleModifier())
            }
    }
}

struct EditFrameCircleModifier: ViewModifier {
    let borderWidth = 4.0

    func body(content: Content) -> some View {
        content

            .frame(width: 16, height: 16)
            .padding(10)
            .background(Circle().fill(Color(.image)))
    }
}
