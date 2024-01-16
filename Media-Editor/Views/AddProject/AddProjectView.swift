//
//  AddProjectView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Kingfisher
import Photos
import SwiftUI

struct AddProjectView: View {
    @StateObject var vm = AddProjectViewModel()

    var body: some View {
        Text("Choose media to your project")
            .padding()
            .font(.title2)
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
