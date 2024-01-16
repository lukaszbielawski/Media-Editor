//
//  UIScreenExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 10/01/2024.
//

import Foundation
import UIKit

extension UIScreen {
    static var bottomSafeArea: CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }.first

        return (keyWindow?.safeAreaInsets.bottom) ?? 0
    }
}
