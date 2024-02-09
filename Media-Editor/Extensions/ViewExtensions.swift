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

    func roundedUpperCorners(_ cornerRadius: Double) -> some View {
        self
            .padding(.bottom, cornerRadius)
            .cornerRadius(cornerRadius)
            .padding(.bottom, -cornerRadius)
    }

    func geometryAccessor(proxy: @escaping (GeometryProxy) -> Void) -> some View {
        self
            .overlay {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            proxy(geo)
                        }
                }
            }
    }
}
