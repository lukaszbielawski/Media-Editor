//
//  PenShape.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 29/04/2024.
//

import SwiftUI

struct PenShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path(ellipseIn: rect)
        return path
    }
}
