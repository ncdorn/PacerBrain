//
//  PacingOptimizer.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/3/25.
//

import Foundation

struct SegmentEffortPlan {
    var efforts: [Double]
    var speeds: [Double]
    var durations: [TimeInterval]
    var totalTime: TimeInterval
}

struct PacingOptimizer {
    var raceType: RaceType
    var segments: [CourseSegment]
    var model: PerformanceModel

    mutating func optimize() {
        switch raceType {
        case .run, .triathlonRun:
            var runOptimizer = RunPaceOptimizer(segments: segments, model: model)
            runOptimizer.optimize()
            segments = runOptimizer.segments  // ⬅️ update with modified segments

        case .bike, .triathlonBike:
            let initialEffort = model.output(at: 3600 * 5)
            let effortBounds = initialEffort * 0.5 ... initialEffort * 2
            var bikeOptimizer = BikePaceOptimizer(
                segments: segments,
                model: model,
                initialEffort: initialEffort,
                effortBounds: effortBounds
            )
            bikeOptimizer.optimize()
            segments = bikeOptimizer.segments  // ⬅️ update with modified segments

        default:
            print("not supported")
        }
    }
}
