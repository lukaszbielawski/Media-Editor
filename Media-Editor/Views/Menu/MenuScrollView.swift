//
//  MenuScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import SwiftUI

struct MenuScrollView: View {
    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 16),
              count: UIDevice.current.userInterfaceIdiom == .phone ? 2 : 4)

    @EnvironmentObject var vm: MenuViewModel

    var dotsDidTapped: (UUID) -> Void

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                MenuUpperView()
                    .frame(height: geo.size.height * 2 / 5)
                LazyVGrid(columns: columns, spacing: 16) {
                    Group {
                        MenuPlaceholderTileView()
                        ForEach(vm.projects
                            .sorted { ($0.lastEditDate ?? Date.distantPast) > ($1.lastEditDate ?? Date.distantPast) },
                            id: \.self)
                        { project in
                            MenuTileView(project: project, dotsDidTapped: dotsDidTapped)
                        }
                        .foregroundStyle(Color(.tint))
                    }
                }
                .padding(16)
            }
        }.onAppear {
            vm.objectWillChange.send()
        }
    }
}
