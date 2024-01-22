//
//  ProjectToolTileViewModifier.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import Foundation
import SwiftUI

struct ProjectToolTileViewModifier: ViewModifier {
    let lowerToolbarHeight: Double
    let padding: Double

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: padding * lowerToolbarHeight))
            .frame(width: lowerToolbarHeight * (1 - 2 * padding), height: lowerToolbarHeight * (1 - 2 * padding))
            .padding(.vertical, padding * lowerToolbarHeight)
            .aspectRatio(1.0, contentMode: .fit)
            .foregroundStyle(Color(.tint))
    }
}
