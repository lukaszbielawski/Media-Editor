//
//  KeyboardHeightService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Combine
import Foundation
import SwiftUI

struct KeyboardNotificationService {
    var keyboardWillShowNotificationPublisher: AnyPublisher<(Animation, CGFloat), KeyboardError>
    var keyboardWillHideNotificationPublisher: AnyPublisher<Double, Never>

    init() {
        keyboardWillShowNotificationPublisher = NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo }
            .tryMap { userInfo in
                guard let keyboardRect =
                    userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else {
                    throw KeyboardError.nilUserInfoValue(forKey: UIResponder.keyboardFrameEndUserInfoKey)
                }

                guard let animationCurveValue =
                    userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
                else {
                    throw KeyboardError.nilUserInfoValue(forKey: UIResponder.keyboardAnimationCurveUserInfoKey)
                }

                guard let animationDuration =
                    userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
                else {
                    throw KeyboardError.nilUserInfoValue(forKey: UIResponder.keyboardAnimationDurationUserInfoKey)
                }

                return (keyboardRect, animationCurveValue, animationDuration)
            }
            .tryCompactMap { keyboardRect, animationCurveValue, animationDuration in
                guard let curve = UIView.AnimationCurve(rawValue: animationCurveValue) else {
                    throw KeyboardError.invalidCurveRawValue(rawValue: animationCurveValue)
                }
                return (animationDuration: curve.convertToAnimation(withDuration: animationDuration),
                        keyboardHeight: keyboardRect.height)
            }
            .mapError {
                guard let keyboardError = $0 as? KeyboardError else { return KeyboardError.other }
                return keyboardError
            }
            .eraseToAnyPublisher()

        keyboardWillHideNotificationPublisher = NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillHideNotification)
            .map { _ in 0.0 }
            .eraseToAnyPublisher()
    }
}
