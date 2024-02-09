//
//  ProjectToolTileViewModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import Foundation
import SwiftUI

struct ProjectToolTileViewModifier: ViewModifier {
    @EnvironmentObject var vm: ImageProjectViewModel
    let padding: Double

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: padding * vm.plane.lowerToolbarHeight))
            .frame(width: vm.plane.lowerToolbarHeight * (1 - 2 * padding), height: vm.plane.lowerToolbarHeight * (1 - 2 * padding))
            .padding(.vertical, padding * vm.plane.lowerToolbarHeight)
            .aspectRatio(1.0, contentMode: .fit)
            .foregroundStyle(Color(.tint))
    }
}
