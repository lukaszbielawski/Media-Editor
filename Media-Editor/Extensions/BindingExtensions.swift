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
        Binding(
            get: {
                log10(self.wrappedValue) / log10(base)
            },
            set: { newValue in
                self.wrappedValue = pow(base, newValue)
            }
        )
    }
}

extension Binding where Value == String {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

extension Binding where Value == CGFloat {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }

    func toString() -> Binding<String> {
        Binding<String>(
            get: {
                String(Int(self.wrappedValue))
            },
            set: { newValue in
                self.wrappedValue = CGFloat(Int(newValue) ?? 0)
            }
        )
    }
}

extension Binding where Value == Color {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
