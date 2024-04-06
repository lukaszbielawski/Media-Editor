//
//  AddProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Photos
import SwiftUI

struct AddProjectView: View {
    @StateObject var vm = AddProjectViewModel()

    var body: some View {
        Text("Choose photos to your project")
            .padding()
            .font(.custom("Kaushan Script", size: 32))
            .foregroundStyle(Color(.tint))
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                AddProjectGridView()
            }
            AddProjectSummaryView()
        }

        .environmentObject(vm)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    AddProjectView()
}
