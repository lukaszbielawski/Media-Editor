//
//  ImageProjectToolFlipAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import SwiftUI
import Combine

struct ImageProjectToolCaseBackgroundView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var cancellable: AnyCancellable?

    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                ColorPicker(selection: $vm.projectModel.backgroundColor, label: { EmptyView() })
                    .labelsHidden()
                    .scaleEffect(vm.plane.lowerToolbarHeight *
                        (1 - 2 * vm.tools.paddingFactor) / 28)

                ImageProjectToolColorTileView(color: $vm.projectModel.backgroundColor, title: "Custom")
                    .allowsHitTesting(false)
            }
            ForEach(vm.tools.colorArray, id: \.self) { color in
                ImageProjectToolColorTileView(color: .constant(color))
                    .onTapGesture {
                        vm.projectModel.backgroundColor = color
                        vm.updateLatestSnapshot()
                        PersistenceController.shared.saveChanges()
                        vm.objectWillChange.send()
                    }
            }
            Spacer()
        }
        .onAppear {
            cancellable = vm.tools.debounceSaveSubject
                .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                .sink { _ in
                    print("up")
                    vm.updateLatestSnapshot()
                    PersistenceController.shared.saveChanges()
                }
        }.onChange(of: vm.projectModel.backgroundColor) { _ in
            vm.tools.debounceSaveSubject.send()
        }
    }
}
