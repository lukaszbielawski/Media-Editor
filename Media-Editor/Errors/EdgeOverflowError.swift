//
//  EdgeOverflowError.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/02/2024.
//

import Foundation

enum EdgeOverflowError: Error {
    case trailing(offset: Double)
    case leading(offset: Double)
    case top(offset: Double)
    case bottom(offset: Double)
}
