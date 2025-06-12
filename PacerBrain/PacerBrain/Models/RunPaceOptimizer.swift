//
//  RunPaceOptimizer.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/3/25.
//


import Foundation

struct RunPaceOptimizer {
    var segments: [CourseSegment]            // 🔄 mutable copy
    let model: PerformanceModel              // duration → velocity curve

    var fatigueRate: Double = 0.04
    var maxSpeedBoost: Double = 1.05

    mutating func optimize() {
        // let totalDistance = segments.map(\.segmentDistance).reduce(0, +)
        let totalDistance = segments.map(\.segmentDistance).reduce(0, +)
        let estimatedRaceTime = totalDistance / model.output(at: 3600 * 1.5)
        let clampedTime = min(max(estimatedRaceTime, 10 * 60), 5 * 3600)
        let baselineSpeed = max(model.output(at: clampedTime), 1.5)
        
        let maxSpeed = model.output(at: 3600) * maxSpeedBoost

        for (i, segment) in segments.enumerated() {
            // Fatigue scaling across race
            let fatigueMultiplier = 1.0 - fatigueRate * (Double(i) / Double(segments.count))
            let fatiguedSpeed = baselineSpeed * fatigueMultiplier

            // Grade adjustment (in percent, so grade = 0.05 means 5%)
            let gradeAdjustedSpeed = adjustSpeed(fatiguedSpeed, for: segment.averageGrade)

            // Cap at max sprint pacing
            let finalSpeed = min(max(gradeAdjustedSpeed, 1.5), maxSpeed)

            let duration = segment.segmentDistance / finalSpeed
            

            segments[i].targetEffort = baselineSpeed
            segments[i].targetSpeed = finalSpeed
            segments[i].targetDuration = duration
        }
    }

    private func adjustSpeed(_ speed: Double, for gradePct: Double) -> Double {
        let penaltyPerPercent = 0.0894

        let adjustedSpeed = speed - (gradePct * penaltyPerPercent)

        // Clamp to minimum viable speed
        return max(adjustedSpeed, 0.5) // don't let it go to 0
    }
}
