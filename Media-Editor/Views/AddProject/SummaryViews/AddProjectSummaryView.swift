//
//  AddProjectSummaryView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import SwiftUI

struct AddProjectSummaryView: View {
    @EnvironmentObject var vm: AddProjectViewModel
    var totalHeight: Double { 100.0 + UIScreen.bottomSafeArea }
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Material.thickMaterial)
                .frame(height: totalHeight)
                .roundedUpperCorners(16)
            AddProjectSummarySliderView()
                .padding(.bottom, UIScreen.bottomSafeArea)
        }
        .animation(.spring(), value: vm.selectedAssets.count == 0)
        .offset(y: vm.selectedAssets.count == 0 ? totalHeight : 0)
    }
}
