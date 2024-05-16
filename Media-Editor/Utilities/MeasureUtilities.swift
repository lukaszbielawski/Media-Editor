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

    static func getMemoryUsage() -> CGFloat {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let usedMb = CGFloat(taskInfo.phys_footprint) / 1048576.0
        let totalMb = CGFloat(ProcessInfo.processInfo.physicalMemory) / 1048576.0
        return result != KERN_SUCCESS ? 0.0 : usedMb / totalMb
    }
}
