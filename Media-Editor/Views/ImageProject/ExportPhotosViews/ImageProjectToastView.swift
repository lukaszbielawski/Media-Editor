//
//  ImageProjectToastView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 27/02/2024.
//

import SwiftUI

struct ImageProjectToastView: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .frame(width: 96, height: 96)

            .foregroundStyle(Color(.image))
            .background(
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(Material.ultraThinMaterial)
                    .frame(width: 128, height: 128)
            )
    }
}
