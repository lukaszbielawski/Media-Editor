//
//  ImageProjectToolFloatingButton.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 23/02/2024.
//

import SwiftUI

struct ImageProjectToolFloatingButtonView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var color: ColorResource = .image
//    var systemName: String = "arrow.uturn.backward"
    let buttonType: FloatingButtonType

    var body: some View {
        ZStack {
            Circle().fill(Color(color))
            Button(action: { [unowned vm] in
                DispatchQueue.main.async {
                    vm.floatingButtonClickedSubject.send(
                        buttonType == .left ?
                            vm.leftFloatingButtonActionType :
                            vm.rightFloatingButtonActionType
                    )
                }
            }, label: {
                Image(systemName: buttonType == .left
                      ? vm.tools.leftFloatingButtonIcon
                      : vm.tools.rightFloatingButtonIcon)
                    .foregroundStyle(Color(.tint))
                    .contentShape(Rectangle())
                    .font(.title)
            })
        }
        .frame(width: vm.plane.lowerToolbarHeight * 0.5,
               height: vm.plane.lowerToolbarHeight * 0.5)
        .padding(.leading, buttonType == .left ? vm.tools.paddingFactor * vm.plane.lowerToolbarHeight : 0)
        .transition(.normalOpacityTransition)
    }
}
