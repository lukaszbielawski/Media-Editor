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

    @Binding var offset: CGFloat

    func body(content: Content) -> some View {
        ZStack {
            Circle()
                .fill(Color(.tint))
                .frame(width: 10.5, height: 10.5)
            content
                .frame(width: 11, height: 11)
                .padding(11 + offset)
        }
        .contentShape(Rectangle().size(width: 50, height: 50))
    }
}
