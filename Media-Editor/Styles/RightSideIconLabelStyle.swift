//
//  RightSideIconLabelStyle.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 30/06/2024.
//

import Foundation
import SwiftUI

struct RightSideIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}
