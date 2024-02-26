//
//  ImageProjectToolFlipAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolCaseBackgroundView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State private var cancellable: AnyCancellable?
    @State private var colorPickerSubject = PassthroughSubject<Void, Never>()

    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                ColorPicker(selection: $vm.projectModel.backgroundColor.onChange(colorPicked), label: { EmptyView() })
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
                    }
            }
            Spacer()
        }.onAppear {
            cancellable =
                colorPickerSubject
                    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                    .sink { [unowned vm] in
                        vm.updateLatestSnapshot()
                        PersistenceController.shared.saveChanges()
                        vm.objectWillChange.send()
                    }
        }
    }

    private func colorPicked(color: Color) {
        colorPickerSubject.send()
    }
}
