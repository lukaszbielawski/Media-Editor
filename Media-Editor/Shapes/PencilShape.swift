//
//  PencilShape.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 28/04/2024.
//

import SwiftUI

struct PencilShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path(ellipseIn: rect)
        return path
    }
}
