//
//  ImageProjectImportPhotoSummary.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import SwiftUI

struct ImageProjectImportPhotoSummary: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    var totalHeight: Double { 100.0 + UIScreen.bottomSafeArea }
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            Rectangle()
                .fill(Material.thickMaterial)
                .frame(height: totalHeight)
                .roundedUpperCorners(16)
            ImageProjectImportPhotoSummaryGridView(totalHeight: totalHeight)
                .padding(.bottom, UIScreen.bottomSafeArea)
        }
        .animation(.spring(), value: vm.selectedPhotos.count)
        .offset(y: vm.selectedPhotos.count == 0 ? totalHeight : 0)
    }
}
