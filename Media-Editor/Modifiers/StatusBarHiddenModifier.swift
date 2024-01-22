//
//  StatusBarHiddenModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import SwiftUI

struct StatusBarHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            content
                .statusBarHidden()
        } else {
            content
        }
    }
}
