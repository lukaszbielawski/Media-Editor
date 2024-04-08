//
//  ImageProjectToolCaseTextCategoryFontNameView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/04/2024.
//

import Foundation

import Combine
import SwiftUI

struct ImageProjectToolCaseTextCategoryFontNameView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var debounceSaveSubject = PassthroughSubject<Void, Never>()
    @State var cancellable: AnyCancellable?

    @FocusState var isFocused

    var body: some View {
        let pickerBinding = Binding<FontType>(
            get: {
                if let textLayer = vm.activeLayer as? TextLayerModel {
                    return FontType.allCases.first { $0.fontName == textLayer.fontName }!
                } else {
                    return .arial
                }
            }, set: { newValue in
                if let textLayer = vm.activeLayer as? TextLayerModel {
                    textLayer.fontName = newValue.fontName
                }
            })

        ZStack(alignment: .bottom) {
            HStack {
                Picker("", selection: pickerBinding.onChange(pickerChanged(newValue:))) {
                    ForEach(FontType.allCasesAlphabetically, id: \.self) { font in
                        Text(font.displayName)
                            .font(.custom(font.fontName, size: 32))
                    }
                }

                .pickerStyle(WheelPickerStyle())
            }
            .frame(height: vm.plane.lowerToolbarHeight + vm.tools.paddingFactor *
                   vm.plane.lowerToolbarHeight)
        }
        .padding(.bottom, vm.tools.paddingFactor *
            vm.plane.lowerToolbarHeight)
        .frame(height: vm.plane.lowerToolbarHeight)
        .onAppear {
            cancellable = debounceSaveSubject
                .sink { [unowned vm] in
                    vm.renderTask?.cancel()
                    vm.renderTask = Task {
                        try await vm.renderTextLayer()
                    }
                    vm.objectWillChange.send()
                }
        }
    }

    private func pickerChanged(newValue: FontType) {
        if let textLayer = vm.activeLayer as? TextLayerModel {
            textLayer.fontName = newValue.fontName
        }
        debounceSaveSubject.send()
    }
}
