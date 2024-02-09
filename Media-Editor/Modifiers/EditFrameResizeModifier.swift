//
//  EditFrameResizeModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/02/2024.
//

import Foundation
import SwiftUI

struct EditFrameResizeModifier: ViewModifier {
    let edge: Edge.Set

    func body(content: Content) -> some View {
        ZStack {
            Circle()
                .fill(Color(.tint))
                .frame(width: 13, height: 13)
            content
                .frame(width: 14, height: 14)
                .padding(5)
        }
        .padding(edge, 2)
    }
}
