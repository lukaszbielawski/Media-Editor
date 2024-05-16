//
//  MeasureUtilities.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/05/2024.
//

import Foundation

struct MeasureUtilities {
    static func functionTime<Result>(function: () throws -> Result) rethrows -> Result {
        print("begin executing")
        let startTime = Date().timeIntervalSince1970
        let functionValue = try function()
        let endTime = Date().timeIntervalSince1970
        let differenceString = String(format: "%.3f", endTime - startTime)
        print("total time", differenceString, "s")
        return functionValue
    }

    static func functionTime<Result>(function: () async throws -> Result) async rethrows -> Result {
        print("begin executing")
        let startTime = Date().timeIntervalSince1970
        let functionValue = try await function()
        let endTime = Date().timeIntervalSince1970
        let differenceString = String(format: "%.3f", endTime - startTime)
        print("total time", differenceString, "s")
        return functionValue
    }
}
