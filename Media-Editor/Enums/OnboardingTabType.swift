//
//  OnboardingTabType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/06/2024.
//

import Foundation
import SwiftUI

enum OnboardingTabType {
    case title
    case basic
    case advanced
    case filters

    @ViewBuilder
    var associatedView: some View {
        switch self {
        case .title:
            OnboardingTabTitleView()
        case .basic:
            OnboardingTabVideoView(videoName: "TabVideoBasicIPhone",
                                   videoExtension: "mp4",
                                   labelText: "Manipulate layers")
        case .advanced:
            OnboardingTabVideoView(videoName: "TabVideoAdvancedIPhone",
                                   videoExtension: "mp4",
                                   labelText: "Use advanced tools")
        case .filters:
            OnboardingTabVideoView(videoName: "TabVideoFiltersIPhone",
                                   videoExtension: "mp4",
                                   labelText: "Apply various filters")
        }
    }

    func next() -> Self? {
        switch self {
        case .title:
            .basic
        case .basic:
            .advanced
        case .advanced:
            .filters
        case .filters:
            nil
        }
    }
}

extension OnboardingTabType: CaseIterable {
    static var allCases: [OnboardingTabType] =
    [.basic, .advanced, .filters]
}
