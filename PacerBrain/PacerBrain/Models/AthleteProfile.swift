//
//  AthleteProfile.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import Foundation
import SwiftData


@Model
class AthleteProfile: ObservableObject {

    var id       = UUID()
    var name     = "Athlete"
    var age: Int
    var weightKg: Double
    var heightCm: Double
    var sex: Sex


    @Relationship(deleteRule: .cascade)
    var swimCurve: PerformanceCurve

    @Relationship(deleteRule: .cascade)
    var bikeCurve: PerformanceCurve

    @Relationship(deleteRule: .cascade)
    var runCurve: PerformanceCurve


    init(
        name: String = "Athlete",
        age: Int = 25,
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
        self.age = age
        self.sex = sex
        self.name = name
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.swimCurve = PerformanceCurve(distancesM: swimDistances, durations: swimDurations, sport: .swim)
        self.bikeCurve = PerformanceCurve(outputs: bikeOutputs, durations: bikeDurations, sport: .bike)
        self.runCurve = PerformanceCurve(distancesM: runDistances, durations: runDurations, sport: .run)
    }
    
    func performanceModel(for raceType: RaceType) -> PerformanceModel? {
        switch raceType {
        case .swim, .triathlonSwim:
            return swimModel
        case .bike, .triathlonBike:
            return bikeModel
        case .run, .triathlonRun:
            return runModel
        }
    }

    // ---------- Fitted Models -------------------------------------------
    var bikeModel: CriticalPowerModel? {
        PerformanceCurveFitter.fit3PModel(from: bikeCurve.points)
    }
    var bikeFTP: Double {
        bikeModel?.output(at: 3600) ?? 0.0
    }

    var runModel: PowerLawModel? {
        PerformanceCurveFitter.fitPowerLaw(from: runCurve.points)
    }
    var thresholdRunPace: Double {
        runModel?.output(at: 3600) ?? 0.0
    }

    var swimModel: SwimDecayModel? {
        PerformanceCurveFitter.fitSwimModel(from: swimCurve.points)
    }
    var criticalSwimSpeed: Double {
        swimModel?.css ?? 0.0
    }
}

enum Sex: String, Codable, CaseIterable, Identifiable, Hashable {
    case male, female, other
    var id: String { rawValue }
}

