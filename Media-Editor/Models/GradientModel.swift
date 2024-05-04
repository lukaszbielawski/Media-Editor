//
//  GradientModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 04/05/2024.
//

import SwiftUI

struct GradientModel: Equatable {
    var stops: [Gradient.Stop] {
        didSet {
            if stops != oldValue {
                gradient = calculateGradient(stops: stops, direction: direction)
                gradientCG = calculateGradientCG(stops: stops, direction: direction)
            }
        }
    }

    var direction: DirectionType {
        didSet {
            if direction != oldValue {
                gradient = calculateGradient(stops: stops, direction: direction)
                gradientCG = calculateGradientCG(stops: stops, direction: direction)
            }
        }
    }

    var gradient: LinearGradient!
    var gradientCG: CGLinearGradient!

    init(stops: [Gradient.Stop], direction: DirectionType) {
        self.stops = stops
        self.direction = direction
        self.gradient = calculateGradient(stops: stops, direction: direction)
        self.gradientCG = calculateGradientCG(stops: stops, direction: direction)
    }

    private func calculateGradient(stops: [Gradient.Stop], direction: DirectionType) -> LinearGradient {
        let directionPoints = direction.getStartEndPoints()
        let deviceRGBStops = stops.map { Gradient.Stop(color: $0.color.toDeviceRGB, location: $0.location) }
        return LinearGradient(gradient: Gradient(stops: deviceRGBStops),
                              startPoint: directionPoints.startPoint,
                              endPoint: directionPoints.endPoint)
    }

    private func calculateGradientCG(stops: [Gradient.Stop], direction: DirectionType) -> CGLinearGradient {
        let directionPoints = direction.getStartEndPoints()
        let deviceRGBStops = stops.map { Gradient.Stop(color: $0.color.toDeviceRGB, location: $0.location) }

        let cgGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: deviceRGBStops.map { $0.color.cgColor } as CFArray,
            locations: deviceRGBStops.map { $0.location })

        return CGLinearGradient(
            cgGradient: cgGradient,
            startPoint: directionPoints.startPoint,
            endPoint: directionPoints.endPoint)
    }

    static func == (lhs: GradientModel, rhs: GradientModel) -> Bool {
        return (lhs.direction, lhs.stops) == (rhs.direction, rhs.stops)
    }
}
