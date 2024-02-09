//
//  PlaneModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/02/2024.
//

import Foundation
import SwiftUI

struct PlaneModel {
    let lowerToolbarHeight: Double = 100

    var totalLowerToolbarHeight: Double?
    var totalNavBarHeight: Double?
    var furthestPlanePointAllowed: CGPoint?
    var currentPosition: CGPoint?
    var initialPosition: CGPoint?
    var size: CGSize?
    var scale: Double? = 1.0


    mutating func setupPlaneView(workspaceSize: CGSize) {
        guard let totalLowerToolbarHeight,
              let totalNavBarHeight else { return }

        currentPosition =
            CGPoint(x: workspaceSize.width / 2,
                    y: (workspaceSize.height - totalLowerToolbarHeight) / 2 + totalNavBarHeight)
        initialPosition = currentPosition

        furthestPlanePointAllowed =
            CGPoint(x: workspaceSize.width,
                    y: workspaceSize.height + totalLowerToolbarHeight)
    }
}
