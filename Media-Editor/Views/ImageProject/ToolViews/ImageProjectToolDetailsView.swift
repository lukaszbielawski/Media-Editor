//
//  ImageProjectToolDetailsView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import SwiftUI

struct ImageProjectToolDetailsView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var isDeleteImageAlertPresented: Bool = false


    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.image)
                .frame(height: vm.plane.lowerToolbarHeight)

            switch vm.currentTool {
            case .add:
                ImageProjectToolCaseAddView()
            case .layers:
                ImageProjectToolCaseLayersView()
            default:
                EmptyView()
            }
        }
    }
}
