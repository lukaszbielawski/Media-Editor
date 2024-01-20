//
//  ProjectCreatedPreferenceKey.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/01/2024.
//

import Foundation
import SwiftUI

struct ProjectCreatedPreferenceKey: PreferenceKey {
    static var defaultValue: ImageProjectEntity?

    static func reduce(value: inout ImageProjectEntity?, nextValue: () -> ImageProjectEntity?) {
        value = nextValue()
    }
}
