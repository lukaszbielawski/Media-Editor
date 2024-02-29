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
        HStack {
            if vm.currentCategory == .none {
                ForEach(FilterCategoryType.allCases) { category in
                    ImageProjectToolFullTileView(title: category.shortName, imageName: category.thumbnailName)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.currentCategory = category
                        }
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                .onAppear {
                    vm.leftFloatingButtonActionType = .back
                }
            } else {
                ForEach(FilterType.allCases.filter { $0.category == vm.currentCategory! }) { filter in
                    ImageProjectToolFullTileView(title: filter.shortName, imageName: filter.thumbnailName)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.currentFilter = filter
                            Task {
                                await vm.applyFilter()
                            }
                        }
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
                .onAppear {
                    vm.leftFloatingButtonActionType = .deselectCategory
                }
            }
            Spacer()
        }
        .onAppear {
            guard let activeLayer = vm.activeLayer else { return }
            vm.originalCGImage = activeLayer.cgImage
        }
        .onReceive(vm.floatingButtonClickedSubject) { [unowned vm] actionType in
            guard let activeLayer = vm.activeLayer else { return }
            if actionType == .deselectCategory {
                vm.currentCategory = .none
                vm.currentFilter = .none
            } else if actionType == .confirm {
                vm.currentTool = .none
                vm.currentCategory = .none
                vm.currentFilter = .none
                Task{
                    try? await vm.saveNewCGImageOnDisk(for: activeLayer)
                }
                vm.updateLatestSnapshot()
            } else if actionType == .back {
                vm.disablePreviewCGImage()
            }
        }
    }
}
