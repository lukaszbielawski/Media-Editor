//
//  AnyTransitionExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

extension AnyTransition {
    static var normalOpacityTransition: AnyTransition {
        AnyTransition.opacity.animation(.easeInOut(duration: 0.35))
    }
}
