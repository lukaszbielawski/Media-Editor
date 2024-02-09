//
//  EditFrameCircleModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/02/2024.
//

import SwiftUI

struct EditFrameCircleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content

            .frame(width: 16, height: 16)
            .padding(10)
            .background(Circle().fill(Color(.image)))
    }
}
