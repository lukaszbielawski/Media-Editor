//
//  KeyboardHeightService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Foundation
import SwiftUI

class KeyboardNotificationService: ObservableObject {
    @Published private var keyboardHeight: CGFloat = 0
    @Published private var animation: Animation?
    
    lazy var keyboardHeightPublisher: Published<CGFloat>.Publisher = _keyboardHeight.projectedValue
    lazy var animationPublisher: Published<Animation?>.Publisher = _animation.projectedValue
    
    init() {
        self.listenForKeyboardNotifications()
    }
    
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main)
        { [unowned self] notification in
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let animationCurveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                  let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curve = UIView.AnimationCurve(rawValue: animationCurveValue) else { return }
            
            self.animation = curve.convertToAnimation(withDuration: animationDuration)
            self.keyboardHeight = keyboardRect.height
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main)
        { [unowned self] _ in
            self.keyboardHeight = 0
        }
    }
}
