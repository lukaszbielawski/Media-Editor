//
//  OnboardingViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import Foundation

final class OnboardingViewModel: ObservableObject {
    @Published var isPurchased: Bool = false
    @Published var currentTab: OnboardingTabType = .title
    @Published var isFreeTrialToggled: Bool = false
    @Published var sheetHeight: CGFloat = 300.0

    var isSheetPresented: Bool {
        currentTab != .title
    }
}
