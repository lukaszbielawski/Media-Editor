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

    var isProjectBackgroundColorChanger: Bool = true

    var body: some View {
        let backgroundColorBinding = isProjectBackgroundColorChanger ?
            $vm.projectModel.backgroundColor :
            $vm.currentLayerBackgroundColor
        HStack {
            ZStack(alignment: .center) {
                ColorPicker(selection: backgroundColorBinding.onChange(colorPicked), label: { EmptyView() })
                    .labelsHidden()
                    .scaleEffect(vm.plane.lowerToolbarHeight *
                        (1 - 2 * vm.tools.paddingFactor) / (UIDevice.current.userInterfaceIdiom == .phone ? 28 : 36))

                ImageProjectToolColorTileView(color: backgroundColorBinding, title: "Custom")
                    .allowsHitTesting(false)
            }
            ForEach(vm.tools.colorArray, id: \.self) { color in
                ImageProjectToolColorTileView(color: .constant(color))
                    .onTapGesture {
                        backgroundColorBinding.wrappedValue = color
                        if isProjectBackgroundColorChanger {
                            vm.updateLatestSnapshot()
                        } else {
                            Task {
                                try await vm.addBackgroundToLayer()
                            }
                        }
                        vm.objectWillChange.send()
                    }
            }
            Spacer()
        }.onAppear {
            cancellable =
                colorPickerSubject
                    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
                    .sink { [unowned vm] in
                        if isProjectBackgroundColorChanger {
                            vm.updateLatestSnapshot()
                        } else {
                            Task {
                                try await vm.addBackgroundToLayer()
                            }
                        }
                        vm.objectWillChange.send()
                    }

            if !isProjectBackgroundColorChanger {
                guard let activeLayer = vm.activeLayer else { return }
                vm.originalCGImage = activeLayer.cgImage?.copy()
            }
        }
    }

    private func colorPicked(color: Color) {
        colorPickerSubject.send()
    }
}
