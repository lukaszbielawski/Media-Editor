//
//  ImageProjectToolTextFloatingTextFieldView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/04/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolTextFloatingTextFieldView: View {
    @Environment(\.colorScheme) var appearance
    @EnvironmentObject var vm: ImageProjectViewModel

    @State var textFieldWidth: Double = 0.0
    let textFieldHeight: CGFloat

    @State private var debounceTextFieldSubject = PassthroughSubject<String, Never>()
    @State private var cancellable: AnyCancellable?
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if let textLayer = vm.activeLayer as? TextLayerModel {
                let textFieldBinding =
                    Binding<String> {
                        textLayer.text
                    } set: { newValue in
                        textLayer.text = newValue
                    }

                TextField("Type text here...", text: textFieldBinding.onChange(debounceTextFieldSubject.send(_:)), onEditingChanged: { editing in
                    if !editing {
                        vm.updateLatestSnapshot()
                    }
                })
                .foregroundStyle(Color(.tint))
                .font(.title2)
                .focused($isFocused)
                .padding(.horizontal, textFieldHeight * 0.25)
                .frame(maxHeight: .infinity)
                .background(Color(.image))
                .clipShape(Capsule(style: .circular))
                .geometryAccessor { geo in
                    DispatchQueue.main.async {
                        textFieldWidth = geo.size.width
                    }
                }
            }
        }
        .frame(maxWidth: 300, maxHeight: vm.plane.lowerToolbarHeight * 0.5)
        .padding(.leading, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
        .transition(.normalOpacityTransition)
        .onAppear {
            cancellable =
                debounceTextFieldSubject
                    .throttleAndDebounce(throttleInterval: .seconds(0.0333),
                                         debounceInterval: .seconds(1.0),
                                         scheduler: DispatchQueue.main)
                    .sink { [unowned vm] _ in
                        print("debounceTextFieldSubject sink")
                        vm.renderTask?.cancel()
                        vm.renderTask = Task {
                            try await vm.renderTextLayer()
                        }
                        vm.objectWillChange.send()
                    }
        }
        .onChange(of: isFocused) { [unowned vm] newValue in
            if newValue {
                vm.leftFloatingButtonActionType = .hideKeyboard
                vm.tools.leftFloatingButtonIcon = "keyboard.chevron.compact.down"
            } else {
                vm.leftFloatingButtonActionType = .back
                vm.tools.leftFloatingButtonIcon = "arrow.uturn.backward"
            }
        }
        .onReceive(vm.floatingButtonClickedSubject) { actionType in
            if actionType == .hideKeyboard {
                isFocused = false
            }
        }
        .onTapGesture {
            isFocused = false
        }
    }
}
