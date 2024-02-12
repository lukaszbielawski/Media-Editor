//
//  EditFrameCircleModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/02/2024.
//

import SwiftUI

struct EditFrameCircleModifier: ViewModifier {
    @EnvironmentObject var vm: ImageProjectViewModel
    var planeScaleFactor: CGFloat { (vm.plane.scale ?? 1.0) - 1.0 }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(.tint))
            .frame(width: 16, height: 16)
            .padding(10)
            .background(Circle().fill(Color(.image)))
    }
}
