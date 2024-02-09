//
//  LayerTransformationModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/02/2024.
//

import SwiftUI

struct LayerTransformationModifier: ViewModifier {
    let scaleX: Double?
    let scaleY: Double?

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: scaleX ?? 1.0, y: scaleY ?? 1.0)
    }
}
