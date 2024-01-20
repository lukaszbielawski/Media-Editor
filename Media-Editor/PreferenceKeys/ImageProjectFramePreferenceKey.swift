//
//  ImageProjectFramePreferenceKey.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 18/01/2024.
//

import Foundation
import SwiftUI

struct ImageProjectFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect?

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue()
    }
}
