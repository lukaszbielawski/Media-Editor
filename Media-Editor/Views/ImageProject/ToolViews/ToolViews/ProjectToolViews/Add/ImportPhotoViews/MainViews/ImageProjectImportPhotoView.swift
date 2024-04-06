//
//  ImageProjectImportPhotoView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import SwiftUI

struct ImageProjectImportPhotoView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        Text("Add photos to your project")
            .padding()
            .font(.custom("Kaushan Script", size: 32))
            .foregroundStyle(Color(.tint))
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                ImageProjectImportPhotoGridView()
            }
            ImageProjectImportPhotoSummary()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
