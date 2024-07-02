//
//  CapsuleBorderStroke.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 02/07/2024.
//

import SwiftUI

struct CapsuleBorderStroke: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .overlay {
                    Capsule()
                        .stroke(lineWidth: 4)
                        .foregroundStyle(.accent2)
                }
        } else {
            content
        }
    }
}
