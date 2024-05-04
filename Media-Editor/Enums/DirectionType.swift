//
//  DirectionType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/05/2024.
//

import SwiftUI

enum DirectionType {
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
    case topLeft

    func getStartEndPoints() -> (startPoint: UnitPoint, endPoint: UnitPoint) {
        switch self {
        case .top:
            (.bottom, .top)
        case .topRight:
            (.bottomLeading, .topTrailing)
        case .right:
            (.leading, .trailing)
        case .bottomRight:
            (.topLeading, .bottomTrailing)
        case .bottom:
            (.top, .bottom)
        case .bottomLeft:
            (.topTrailing, .bottomLeading)
        case .left:
            (.trailing, .leading)
        case .topLeft:
            (.bottomTrailing, .topLeading)
        }
    }

    var nextClockwiseDirection: Self {
        switch self {
        case .top:
            .topRight
        case .topRight:
            .right
        case .right:
            .bottomRight
        case .bottomRight:
            .bottom
        case .bottom:
            .bottomLeft
        case .bottomLeft:
            .left
        case .left:
            .topLeft
        case .topLeft:
            .top
        }
    }

    var rotationAngle: Angle {
        switch self {
        case .top:
            Angle(degrees: 0.0)
        case .topRight:
            Angle(degrees: 45.0)
        case .right:
            Angle(degrees: 90.0)
        case .bottomRight:
            Angle(degrees: 135.0)
        case .bottom:
            Angle(degrees: 180.0)
        case .bottomLeft:
            Angle(degrees: 225.0)
        case .left:
            Angle(degrees: 270.0)
        case .topLeft:
            Angle(degrees: 315.0)
        }
    }
}
