//
//  EditFrameResizeModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/02/2024.
//

import Foundation
import SwiftUI

struct EditFrameResizeModifier: ViewModifier {
    @EnvironmentObject var vm: ImageProjectViewModel

    let edge: Edge.Set
    var planeScaleFactor: CGFloat { (vm.plane.scale ?? 1.0) - 1.0 }

    func body(content: Content) -> some View {
        ZStack {
            Circle()
                .fill(Color(.tint))
                .frame(width: 13, height: 13)
            content
                .frame(width: 14, height: 14)
                .padding(5)
        }
        .padding(edge, 2 - 0.2 * planeScaleFactor)
    }
}
