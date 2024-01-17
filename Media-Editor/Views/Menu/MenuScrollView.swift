//
//  MenuScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Kingfisher
import SwiftUI

struct MenuScrollView: View {
    private let columns =
        Array(repeating: GridItem(.flexible(), spacing: 16), count: UIDevice.current.userInterfaceIdiom == .phone ? 2 : 4)

    @EnvironmentObject var vm: MenuViewModel

    var dotsDidTapped: (UUID) -> ()

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                MenuUpperView()
                    .frame(height: geo.size.height * 2 / 5)
                LazyVGrid(columns: columns, spacing: 16) {
                    Group {
                        MenuPlaceholderTileView()

                        ForEach($vm.projects) { $project in
                            MenuTileView(project: $project, dotsDidTapped: dotsDidTapped)
                        }
                        .foregroundStyle(Color(.white))
                    }
                    .cornerRadius(16.0)
                }
                .padding(16)
            }
        }
    }
}

#Preview {
//    let preview = PersistenceController.shared.preview
//    let bindingArray: Binding<[ProjectEntity]> = .constant(preview)
    let vm = MenuViewModel()
    vm.projects = PersistenceController.preview.projectController.fetchAll()
    return MenuScrollView { _ in }.environmentObject(vm)
}
