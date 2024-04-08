//
//  PublisherExtensions.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/04/2024.
//

import Combine
import Foundation

extension Publisher {
    func throttleAndDebounce<S>(throttleInterval: S.SchedulerTimeType.Stride, debounceInterval: S.SchedulerTimeType.Stride, scheduler: S) -> AnyPublisher<(Output, ThrottleAndDebounceType), Failure> where S: Scheduler {
        return self
            .debounce(for: debounceInterval, scheduler: scheduler)
            .map { ($0, .debounce) }
            .merge(with:
                self
                    .map { ($0, .throttle) }
                    .throttle(for: throttleInterval, scheduler: scheduler, latest: true)
            )
            .eraseToAnyPublisher()
    }
}
