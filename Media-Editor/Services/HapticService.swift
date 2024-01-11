//
//  HapticService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Foundation
import UIKit

class HapticService {
    static let shared = HapticService()

    private init() {}

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }

    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
