//
//  AthleteProfile.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import Foundation
import SwiftData

// MARK: - Athlete Profile

@Model
final class AthleteProfile: ObservableObject {
    // ---------- Identity ---------------------------------------------------
    var id       = UUID()
    var name     = "Athlete"
    var weightKg: Double
    var heightCm: Double
    var sex: Sex

    // ---------- Performance Curves ----------------------------------------
    @Relationship(deleteRule: .cascade)
    var swimCurve: PerformanceCurve<Dimension>

    @Relationship(deleteRule: .cascade)
    var bikeCurve: PerformanceCurve<Dimension>

    @Relationship(deleteRule: .cascade)
    var runCurve: PerformanceCurve<Dimension>

    // ---------- Initializer -----------------------------------------------
    init(
        name: String = "Athlete",
        sex: Sex = .male,
        weightKg: Double = 75.0,
        heightCm: Double = 178.0,
        swimDistances: [Double] = [],
        swimDurations: [Double] = [],
        runDistances: [Double]  = [],
        runDurations: [Double]  = [],
        bikeOutputs: [Double]  = [],
        bikeDurations: [Double]  = []
    ) {
        self.id = UUID()
        self.sex = sex
        self.name = name
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.swimCurve = PerformanceCurve(distancesM: swimDistances, durations: swimDurations, sport: .swim)
        self.bikeCurve = PerformanceCurve(outputs: bikeOutputs, durations: bikeDurations, sport: .bike)
        self.runCurve = PerformanceCurve(distancesM: runDistances, durations: runDurations, sport: .run)
    }

    // ---------- Derived Metrics -------------------------------------------
    var css: Measurement<Dimension>? {
//        guard
//            let t400 = swimCurve.output(atDistance: 400, poolLength: 50),
//            let t200 = swimCurve.output(atDistance: 200, poolLength: 50)
//        else { return nil }
//        let cssVal = (400.0 - 200.0) / (t400 - t200)          // m s⁻¹
//        return .init(value: cssVal, unit: UnitSpeed.metersPerSecond)
        return nil
    }

    var ftp: Measurement<Dimension>? {
        Measurement(value: bikeCurve.output(at: 3600) ?? 0, unit: UnitPower.watts)
    }

    var criticalSpeed: Measurement<Dimension>? {
        Measurement(value: runCurve.output(at: 360) ?? 0, unit: UnitSpeed.metersPerSecond)
    }
}

enum Sex: String, Codable, CaseIterable, Identifiable, Hashable {
    case male, female, other
    var id: String { rawValue }
}


