//
//  BikePaceOptimizer.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/3/25.
//
import Foundation

struct BikePaceOptimizer {
    var segments: [CourseSegment]
    let model: PerformanceModel
    let initialEffort: Double
    let effortBounds: ClosedRange<Double>
    let maxIterations: Int = 1000

    mutating func optimize() {
        var bestEfforts = Array(repeating: initialEffort, count: segments.count)
        var bestSpeeds = [Double](repeating: 0, count: segments.count)
        var bestDurations = [TimeInterval](repeating: 0, count: segments.count)
        var bestTime = totalRaceTime(for: bestEfforts, speeds: &bestSpeeds, durations: &bestDurations)

        for _ in 0..<maxIterations {
            let trialEfforts = bestEfforts.map { effort in
                let delta = Gaussian.random(mean: 0, stdev: 2.0)
                return (effort + delta).clamped(to: effortBounds)
            }

            var trialSpeeds = [Double](repeating: 0, count: segments.count)
            var trialDurations = [TimeInterval](repeating: 0, count: segments.count)
            let trialTime = totalRaceTime(for: trialEfforts, speeds: &trialSpeeds, durations: &trialDurations)

            if trialTime < bestTime {
                bestEfforts = trialEfforts
                bestSpeeds = trialSpeeds
                bestDurations = trialDurations
                bestTime = trialTime
            }
        }

        // Assign results back to segments
        for i in segments.indices {
            segments[i].targetEffort = bestEfforts[i]
            segments[i].targetSpeed = bestSpeeds[i]
            segments[i].targetDuration = bestDurations[i]
        }
    }

    private func totalRaceTime(
        for efforts: [Double],
        speeds: inout [Double],
        durations: inout [TimeInterval]
    ) -> TimeInterval {
        var totalEffort: Double = 0
        var totalTime: TimeInterval = 0

        for (i, (effort, segment)) in zip(efforts, segments).enumerated() {
            let speed = speedFromEffort(effort: effort, gradePct: segment.averageGrade)
            let duration = segment.segmentDistance / speed
            let sustainableEffort = model.output(at: duration)

            // Reject plans with unsustainable effort
            if duration <= 0 || effort > sustainableEffort {
                return .infinity
            }

            speeds[i] = speed
            durations[i] = duration
            totalEffort += effort * duration
            totalTime += duration
        }

        let avgEffort = totalEffort / totalTime
        let sustainableAvg = model.output(at: totalTime)

        if avgEffort > sustainableAvg {
            return .infinity
        }

        return totalTime
    }

    func speedFromEffort(
        effort: Double,
        gradePct: Double,
        cda: Double = 0.3,
        mass: Double = 75.0,
        rollingResistance: Double = 0.004,
        airDensity: Double = 1.226,
        tolerance: Double = 0.01,
        maxIterations: Int = 100
    ) -> Double {
        guard effort > 0 else { return 0 }

        let grade = gradePct / 100.0
        let g = 9.81

        func power(at v: Double) -> Double {
            let aero = 0.5 * airDensity * cda * pow(v, 3)
            let rolling = mass * g * rollingResistance * v
            let climbing = mass * g * grade * v
            return aero + rolling + climbing
        }

        func derivative(at v: Double) -> Double {
            let aeroDeriv = 1.5 * airDensity * cda * pow(v, 2)
            let rollingClimbDeriv = mass * g * (rollingResistance + grade)
            return aeroDeriv + rollingClimbDeriv
        }

        var v = max(1.0, sqrt(effort / (0.5 * airDensity * cda)) / 3.0)

        for _ in 0..<maxIterations {
            let f = power(at: v) - effort
            let fPrime = derivative(at: v)
            guard abs(fPrime) > 1e-6 else { break }

            let vNext = v - f / fPrime
            guard vNext.isFinite, vNext > 0.1, vNext < 100 else { break }

            if abs(vNext - v) < tolerance {
                return vNext
            }

            v = vNext
        }

        // Fallback: Bisection
        var a: Double = 0.1
        var b: Double = 50.0
        var mid: Double = (a + b) / 2

        for _ in 0..<maxIterations {
            mid = (a + b) / 2
            let p = power(at: mid)

            if abs(p - effort) < tolerance {
                return mid
            }

            if p > effort {
                b = mid
            } else {
                a = mid
            }
        }

        print("⚠️ Bisection used; returning speed ≈ \(mid)")
        return mid
    }
}

// Helper extensions and structs
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

struct Gaussian {
    static func random(mean: Double = 0, stdev: Double = 1) -> Double {
        let u1 = Double.random(in: 0..<1)
        let u2 = Double.random(in: 0..<1)
        return mean + stdev * sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
    }
}
