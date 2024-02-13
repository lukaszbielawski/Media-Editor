//
//  BindingExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 13/02/2024.
//

import Foundation
import SwiftUI

extension Binding where Value == CGFloat {
    func logarithmic(base: CGFloat = 10) -> Binding<CGFloat> {
        Binding.init(
            get: {
                log10(self.wrappedValue) / log10(base)
            },
            set: { (newValue) in
                self.wrappedValue = pow(base, newValue)
            })
    }
}
