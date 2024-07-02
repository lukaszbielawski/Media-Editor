//
//  SubscriptionType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 02/07/2024.
//

import Foundation

enum SubscriptionType: Identifiable, CaseIterable {
    
    case oneMonth
    case oneYear
    case oneMonthWithFreeTrial
    case oneYearWithFreeTrial

    var id: String {
        switch self {
        case .oneMonth:
            "lukaszbielawski.Pixiva.OneMonthPremium"
        case .oneYear:
            "lukaszbielawski.Pixiva.OneYearPremium"
        case .oneMonthWithFreeTrial:
            "lukaszbielawski.Pixiva.OneMonthPremiumFree3DayTrial"
        case .oneYearWithFreeTrial:
            "lukaszbielawski.Pixiva.OneYearPremiumFree3DayTrial"
        }
    }

    var toggleTrial: Self {
        switch self {
        case .oneMonth:
                .oneMonthWithFreeTrial
        case .oneYear:
                .oneYearWithFreeTrial
        case .oneMonthWithFreeTrial:
                .oneMonth
        case .oneYearWithFreeTrial:
                .oneYear
        }
    }
}
