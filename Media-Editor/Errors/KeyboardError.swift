//
//  KeyboardError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import Foundation

enum KeyboardError: Error {
    case nilUserInfoValue(forKey: Any)
    case invalidCurveRawValue(rawValue: Int)
    case other
}

extension KeyboardError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nilUserInfoValue(let key):
            return "A nil value for the userInfo dict for key \(key) occurced."
        case .invalidCurveRawValue(let rawValue):
            return "Could not create a curve for rawValue \(rawValue)"
        default:
            return nil
        }
    }
}
