//
//  AddProjectGridView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import SwiftUI

struct AddProjectGridView: View {
    @EnvironmentObject var vm: AddProjectViewModel

    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 4), count: UIDevice.current.userInterfaceIdiom == .phone ? 3 : 5)

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(vm.media, id: \.localIdentifier) { media in
                    ZStack {
                        AddProjectGridTileView(media: media)
                    }
                }
            }
        }
        .padding(4)
    }
}
