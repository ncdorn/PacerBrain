//
//  PerformanceCurve.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import Foundation
import SwiftData


@Model
class PerformanceCurve<Dimension>: ObservableObject {
    /// Ascending by `duration`.
    @Attribute(.externalStorage)            // stored efficiently in SwiftData
    
    // MARK: Data In
    var points: [PerformancePoint]
    var sport: Sport
    
    var title: String {
        switch sport {
        case .bike: return "Bike Power Curve"
        case .run: return "Run Velocity Curve"
        case .swim: return "Swim Velocity Curve"
        }
    }
    var distances: [Double]?
    
    
    // MARK: – Designated Init
    /// Initialize directly from already-computed Measurements.
    init(points: [PerformancePoint], sport: Sport) {
        self.points = points.sorted { $0.duration < $1.duration }
        self.sport  = sport
    }

    // MARK: – Convenience Inits

    /// From raw output values (watts or m/s), exactly like before.
    convenience init(
        outputs:   [Double],
        durations: [TimeInterval],
        sport:     Sport
    ) {

        let points = zip(durations, outputs).map { duration, output in
            switch sport {
            case .bike: PerformancePoint(duration: duration, output: output, unit: UnitPower.watts)
            case .swim, .run: PerformancePoint(duration: duration, output: output, unit: UnitSpeed.metersPerSecond)
            }
        }

        self.init(points: points, sport: sport)
    }

    /// From distances + times → computes velocities for you (only for swim/run).
    convenience init(
        distancesM: [Double],
        durations: [TimeInterval],
        sport:     Sport
    ) {
        precondition(
            sport == .run || sport == .swim,
            "Distance-based init only valid for run/swim curves"
        )

        let points = zip(durations, distancesM).map { duration, dist in
            let speedMS = dist / duration
            return PerformancePoint(duration: duration, output: speedMS, unit: UnitSpeed.metersPerSecond, distance: dist)
        }

        self.init(points: points, sport: sport)
    }


    /// Convenience: highest sustainable output at the given duration
    /// (linear interpolation, flat-spot extrapolation).
    func output(at duration: TimeInterval) -> Double? {
        guard let first = points.first else { return nil }
        if duration <= first.duration { return first.output.value }
        for (lhs, rhs) in zip(points, points.dropFirst()) {
            if duration <= rhs.duration {
                let ratio = (duration - lhs.duration) / (rhs.duration - lhs.duration)
                let interpolated = lhs.output.value + ratio * (rhs.output.value - lhs.output.value)
                return interpolated
            }
        }
        return points.last?.output.value // flat extrapolation for long durations
    }

    /// Append or replace a point, keeping the array sorted.
    func insert(_ new: PerformancePoint) {
        if let idx = points.firstIndex(where: { $0.duration == new.duration }) {
            points[idx] = new
        } else {
            points.append(new)
            points.sort { $0.duration < $1.duration }
        }
    }

    /// Replace the entire curve with new mean-max data (e.g. from a workout).
    func replace(with newPoints: [PerformancePoint]) {
        points = newPoints.sorted { $0.duration < $1.duration }
    }
}

// MARK: - PerformancePoint

/// One point on a mean-max curve (duration → output).
struct PerformancePoint: Codable, Hashable {
    var duration: TimeInterval
    var id = UUID()
    var output: Measurement<Dimension>
    var distanceValue: Double? // distance in km
    var distance: Double {
        get { distanceValue ?? 0 }
        set {
            distanceValue = newValue // distance in km
            outputValue = newValue / duration // velocity in m/s
            }
    }
    
    var minutes: Double { duration.rounded(.down) / 60 }
    var seconds: Double { duration.truncatingRemainder(dividingBy: 60) }

    var outputValue: Double {
        get { output.value }
        set { output = Measurement(value: newValue, unit: output.unit) }
    }
    
    init(duration: TimeInterval, output: Double, unit: Dimension, distance: Double? = nil) {
        self.duration = duration
        self.output   = Measurement(value: output, unit: unit)
        self.distanceValue = distance
    }

}

// MARK: - Discipline

/// Supported endurance disciplines.
enum Sport: String, CaseIterable, Codable, Hashable {
    case swim, bike, run
}
