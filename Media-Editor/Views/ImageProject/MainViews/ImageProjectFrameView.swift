//
//  ImageProjectFrameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import Combine
import SwiftUI

struct ImageProjectFrameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var orientation: Image.Orientation = .up

    @State var subscribtion: AnyCancellable?

    var body: some View {
        if vm.workspaceSize != nil {
            Image("AlphaVector")
                .resizable(resizingMode: .tile)
                .overlay {
                    vm.projectModel.backgroundColor
                }
                .frame(width: vm.frame.rect?.size.width ?? 0.0, height: vm.frame.rect?.size.height ?? 0.0)
                .shadow(radius: 10.0)
                .onAppear {
                    vm.frame.rect = vm.calculateFrameRect()

                    subscribtion = vm.layoutChangedSubject
                        .debounce(for: .seconds(5.0), scheduler: DispatchQueue.main)
                        .sink { [unowned vm] in
                            Task {
                                await vm.saveThumbnailToDisk()
                            }
                        }
                }
                .onDisappear {
                    subscribtion?.cancel()
                    subscribtion = nil
                }
        }
    }
}
