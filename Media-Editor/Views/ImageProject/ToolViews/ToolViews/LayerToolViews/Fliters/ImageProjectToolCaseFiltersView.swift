//
//  ImageProjectToolFiltersAddView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import SwiftUI

struct ImageProjectToolCaseFiltersView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if vm.currentCategory == nil {
                    ForEach(FilterCategoryType.allCases) { category in
                        ImageProjectToolFullTileView(title: category.shortName,
                                                     imageName: category.thumbnailName,
                                                     font: .caption)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.currentCategory = category
                            }
                    }
                    .transition(.normalOpacityTransition)
                    .onAppear {
                        vm.leftFloatingButtonActionType = .back
                    }
                } else if let currentCategory = vm.currentCategory as? FilterCategoryType {
                    ForEach(FilterType.allCases.filter { $0.category == currentCategory }) { filter in
                        ImageProjectToolFullTileView(title: filter.shortName,
                                                     imageName: filter.thumbnailName,
                                                     font: .caption)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                vm.currentFilter = filter
                                vm.filterChangedSubject.send()
                                Task {
                                    await vm.applyFilter()
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
        }
        .onAppear {
            guard let activeLayer = vm.activeLayer else { return }
            vm.originalCGImage = activeLayer.cgImage?.copy()
        }
        .onReceive(vm.floatingButtonClickedSubject) { [unowned vm] actionType in
            guard let activeLayer = vm.activeLayer else { return }
            if actionType == .backToCategories {
                vm.disablePreviewCGImage()
                vm.currentCategory = .none
                vm.currentFilter = .none
            } else if actionType == .confirm {
                vm.currentTool = .none
                vm.currentCategory = .none
                vm.currentFilter = .none
                Task {
                    try? await vm.saveNewCGImageOnDisk(fileName: activeLayer.fileName, cgImage: activeLayer.cgImage)
                }
                vm.updateLatestSnapshot()
            }
        }
    }
}
