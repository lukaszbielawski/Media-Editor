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

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: vm.tools.paddingFactor * vm.plane.lowerToolbarHeight))
            .frame(width: vm.plane.lowerToolbarHeight * (1 - 2 * vm.tools.paddingFactor),
                   height: vm.plane.lowerToolbarHeight * (1 - 2 * vm.tools.paddingFactor))
            .padding(.vertical, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
            .aspectRatio(1.0, contentMode: .fit)
            .foregroundStyle(Color(.tint))
    }
}
