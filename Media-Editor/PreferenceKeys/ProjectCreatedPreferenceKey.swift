//
//  ProjectCreatedPreferenceKey.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/01/2024.
//

import Foundation
import SwiftUI

struct ProjectCreatedPreferenceKey: PreferenceKey {
    static var defaultValue: ProjectEntity? = nil

    static func reduce(value: inout ProjectEntity?, nextValue: () -> ProjectEntity?) {
        value = nextValue()
    }
}
