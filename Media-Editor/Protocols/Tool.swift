//
//  Tool.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation

protocol Tool: Identifiable, CaseIterable, RawRepresentable, Equatable where RawValue == String {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
}

//extension Tool {
//    static func ==(lhs: Self, rhs: Self) -> Bool {
//           return false
//       }
//}
