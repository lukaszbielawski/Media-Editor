//
//  ImageProjectToolFiltersAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import SwiftUI

struct ImageProjectToolCaseFiltersView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ZStack {
            HStack {
                ForEach(FilterType.allCases) { filter in
                    ImageProjectToolFullTileView(title: filter.filterShortName, imageName: filter.photoName)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.currentFilter = filter
                        }
                }
                Spacer()
            }
        }
        .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
    }
}
