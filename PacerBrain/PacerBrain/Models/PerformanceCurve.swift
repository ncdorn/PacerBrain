//
//  PerformanceCurve.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import Foundation
import SwiftData


@Model
final class PerformanceCurve: ObservableObject {
    @Relationship(deleteRule: .cascade)
    var points: [PerformancePoint] {
            didSet {
                points.sort { $0.duration < $1.duration }
            }
        }

    var sport: Sport

    var title: String {
        switch sport {
        case .bike: return "Bike Power Curve"
        case .run: return "Run Velocity Curve"
        case .swim: return "Swim Velocity Curve"
        }
    }

    init(points: [PerformancePoint] = [], sport: Sport) {
        self.points = points.sorted { $0.duration < $1.duration }
        self.sport = sport
    }

    convenience init(outputs: [Double], durations: [TimeInterval], sport: Sport) {
        let unit = sport == .bike ? "W" : "m/s"
        let points = zip(durations, outputs).map {
            PerformancePoint(duration: $0.0, outputValue: $0.1, unitSymbol: unit)
        }
        self.init(points: points, sport: sport)
    }

    convenience init(distancesM: [Double], durations: [TimeInterval], sport: Sport) {
        precondition(sport == .run || sport == .swim, "Distance-based init only valid for run/swim curves")
        let unit = "m/s"
        let points = zip(durations, distancesM).map { duration, dist in
            let speedMS = dist / duration
            return PerformancePoint(duration: duration, outputValue: speedMS, unitSymbol: unit, distanceValue: dist)
        }
        self.init(points: points, sport: sport)
    }

    func output(at duration: TimeInterval) -> Double? {
        guard let first = points.first else { return nil }
        if duration <= first.duration { return first.outputValue }

        for (lhs, rhs) in zip(points, points.dropFirst()) {
            if duration <= rhs.duration {
                let ratio = (duration - lhs.duration) / (rhs.duration - lhs.duration)
                return lhs.outputValue + ratio * (rhs.outputValue - lhs.outputValue)
            }
        }
        return points.last?.outputValue
    }

    func insert(_ new: PerformancePoint) {
        if let idx = points.firstIndex(where: { $0.duration == new.duration }) {
            points[idx] = new
        } else {
            points.append(new)
            points.sort { $0.duration < $1.duration }
        }
    }

    func replace(with newPoints: [PerformancePoint]) {
        points = newPoints.sorted { $0.duration < $1.duration }
    }
}

// MARK: - PerformancePoint
@Model
class PerformancePoint: Identifiable {
    var id: UUID
    var duration: TimeInterval
    var outputValue: Double   // The numeric value (watts or m/s)
    var unitSymbol: String    // "W" or "m/s" for display purposes
    var distanceValue: Double?

    init(duration: TimeInterval, outputValue: Double, unitSymbol: String, distanceValue: Double? = nil) {
        self.id = UUID()
        self.duration = duration
        self.outputValue = outputValue
        self.unitSymbol = unitSymbol
        self.distanceValue = distanceValue
    }

    var distance: Double {
        get { distanceValue ?? 0 }
        set {
            distanceValue = newValue
            outputValue = newValue / duration
        }
    }

    var minutes: Double { duration.rounded(.down) / 60 }
    var seconds: Double { duration.truncatingRemainder(dividingBy: 60) }
}


// Supported endurance disciplines.
enum Sport: String, CaseIterable, Codable, Hashable {
    case swim, bike, run
}
