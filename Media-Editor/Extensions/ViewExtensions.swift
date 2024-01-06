//
//  ViewExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Foundation
import SwiftUI

extension View {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}
