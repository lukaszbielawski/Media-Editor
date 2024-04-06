//
//  MenuUpperView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import Foundation
import SwiftUI

struct MenuUpperView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Pixiva")
                .font(.init(.custom("Kaushan Script", size: 144)))
            Text("Photo & Layer Editor")
                .font(.init(.custom("Kaushan Script", size: 32)))
        }
        .foregroundStyle(Color(.tint))
    }
}
