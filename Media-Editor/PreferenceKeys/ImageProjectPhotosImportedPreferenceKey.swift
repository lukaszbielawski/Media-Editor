//
//  ImageProjectPhotosImportedPreferenceKey.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/01/2024.
//

import Foundation
import SwiftUI

struct ImageProjectPhotosImportedPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
