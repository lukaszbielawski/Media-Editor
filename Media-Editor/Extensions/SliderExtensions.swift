//
//  SliderExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/02/2024.
//

import Foundation
import SwiftUI
extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    static func withLog10Scale(
        value: Binding<CGFloat>,
        in range: ClosedRange<CGFloat>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) -> Slider {
        return self.init(
            value: value.logarithmic(),
            in: log10(range.lowerBound) ... log10(range.upperBound),
            onEditingChanged: onEditingChanged
        )
    }
}
