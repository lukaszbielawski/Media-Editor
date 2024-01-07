//
//  ScrollViewExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 07/01/2024.
//

import Foundation
import SwiftUI

//extension ScrollView {
//    func onScrollPerformingToEnd(action: @escaping () -> Void) -> some View {
//        ScrollViewReader { proxy in
//            self.background {
//                GeometryReader { geometry in
//                    let offset = geometry.frame(in: .global).maxY
//                    let height = geometry.frame(in: .global).maxY
//
//                    if offset > 0 && offset + 100 >= height {
//                        action()
//                    }
//                }
//                .onAppear {
//                    action()
//                }
//            }
//        }
//    }
//}
