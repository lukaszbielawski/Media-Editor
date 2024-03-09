//
//  ShapeBuilder.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/03/2024.
//

import Foundation
import SwiftUI

@resultBuilder
public enum ShapeBuilder {
    public static func buildBlock<C0: Shape>(_ c0: C0) -> C0 { c0 }
}

public extension ShapeBuilder {
    static func buildEither<First: Shape, Second: Shape>(first: First) -> EitherShape<First, Second> {
        return .first(first)
    }

    static func buildEither<First: Shape, Second: Shape>(second: Second) -> EitherShape<First, Second> {
        return .second(second)
    }
}

public enum EitherShape<First: Shape, Second: Shape>: Shape {
    case first(First)
    case second(Second)

    public func path(in rect: CGRect) -> Path {
        switch self {
        case .first(let first): return first.path(in: rect)
        case .second(let second): return second.path(in: rect)
        }
    }
}
