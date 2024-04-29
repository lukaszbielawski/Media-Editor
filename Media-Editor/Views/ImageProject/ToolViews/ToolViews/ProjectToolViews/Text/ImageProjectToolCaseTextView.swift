//
//  ImageProjectToolCaseTextView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/04/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolCaseTextView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var isEditMode: Bool = false

    var body: some View {
        ZStack {
            if vm.currentCategory == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(TextCategoryType.allCases) { category in
                            ImageProjectToolTileView(title: category.shortName,
                                                     iconName: category.thumbnailName)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    vm.currentCategory = category
                                }
                        }
                        .transition(.normalOpacityTransition)
                        .onAppear {
                            vm.leftFloatingButtonActionType = .back
                        }
                    }
                }
            } else if let textCategory = vm.currentCategory as? TextCategoryType {
                Group {
                    switch textCategory {
                    case .textColor:
                        ImageProjectToolColorPickerView(colorPickerType: .textColor)
                    case .fontName:
                        ImageProjectToolCaseTextCategoryFontNameView()
                    case .fontSize:
                        ImageProjectToolCaseTextSliderView(textCategory: .fontSize)
                    case .curve:
                        ImageProjectToolCaseTextSliderView(textCategory: .curve)
                    case .border:
                        HStack {
                            ImageProjectToolColorPickerView(
                                colorPickerType: .borderColor,
                                onlyCustom: true,
                                customTitle: "Border")
                            ImageProjectToolCaseTextSliderView(textCategory: .border)
                        }
                    }
                }
                .transition(.normalOpacityTransition)
                .onAppear {
                    vm.leftFloatingButtonActionType = .backToCategories
                }
            }
            Spacer()
        }
        .task {
            if !isEditMode {
                do {
                    let textLayer = try await vm.createTextLayer()
                    vm.activeLayer = textLayer
                } catch {
                    print(error)
                }
            }
        }
        .onReceive(vm.floatingButtonClickedSubject) { [unowned vm] actionType in
            if actionType == .backToCategories {
                vm.currentCategory = .none
            } else if actionType == .back {
                vm.currentTool = .none
            }
        }
    }
}
