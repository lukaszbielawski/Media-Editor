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

    let lowerToolbarHeight: Double
    let padding: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.image)
                .frame(height: lowerToolbarHeight)

            switch vm.currentTool {
            case .add:
                ImageProjectToolCaseAddView(lowerToolbarHeight: lowerToolbarHeight, padding: padding)
//            case .layers:
//                ImageProjectToolCaseAddView(lowerToolbarHeight: lowerToolbarHeight, padding: padding)
            default:
                EmptyView()
            }
        }
    }
}
