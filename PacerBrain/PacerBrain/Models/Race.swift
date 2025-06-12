//
//  Race.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/27/25.
//

import Foundation
import SwiftData

@Model
class Race: Identifiable {
    var id = UUID()
    var name: String
    var date: Date
    var location: String
    var notes: String = ""
    var gpxData: Data? = nil
    var type: RaceType
    var locationName: String = ""
    var latitude: Double?
    var longitude: Double?
    var units: UnitSystem
    
    // MARK: Race Info
    var pacingIsOptimized: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \CourseSegment.race)
    var courseSegments: [CourseSegment] = []
    var totalDistance: Double {
        courseSegments.reduce(0) { $0 + $1.segmentDistance }
    }
    var totalTime: TimeInterval {
        courseSegments.reduce(0) { $0 + ($1.targetDuration ?? 0) }
    }
    var totalWork: Double {
        courseSegments.reduce(0) { $0 + (($1.targetEffort ?? 0) * ($1.targetDuration ?? 0))}
    }
    
    var averagePowerOrPace: String {
        guard !courseSegments.isEmpty else { return "N/A" }
        
        switch type {
        case .bike, .triathlonBike:
            
            let avgPower = totalTime > 0 ? totalWork / totalTime : 0.0
            return String(format: "%.0f W", avgPower)
            
        case .run, .triathlonRun, .swim, .triathlonSwim:
            let speedMS = totalDistance > 0 ? totalDistance / totalTime : 0.0
            return formattedRunPace(speedMS: speedMS, units: units)
        }
    }
    
    var averageSpeed: Double {
        let speedMps = totalTime > 0 ? totalDistance / totalTime : 0.0
        return speedMps
    }

    // MARK: init
    init(name: String = "",
         date: Date = .now,
         location: String = "",
         notes: String = "",
         gpxData: Data? = nil,
         type: RaceType = .run,
         units: UnitSystem = .metric) {
        self.name = name
        self.date = date
        self.location = location
        self.notes = notes
        self.gpxData = gpxData
        self.type = type
        self.units = units
    }

    // MARK: Elevation Profile
    var storedElevationProfile: ElevationProfile?

    var elevationProfile: ElevationProfile? {
        storedElevationProfile ?? {
            guard let gpxData else { return nil }
            return ElevationProfile(gpxData: gpxData)
        }()
    }
}

enum RaceType: String, CaseIterable, Codable, Identifiable {
    case swim = "Swim"
    case bike = "Bike"
    case run = "Run"
    case triathlonSwim = "Triathlon Swim"
    case triathlonBike = "Triathlon Ride"
    case triathlonRun = "Triathlon Run"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .swim: return "figure.open.water.swim"
        case .bike: return "figure.outdoor.cycle"
        case .run: return "figure.run"
        case .triathlonSwim: return "figure.open.water.swim.circle"
        case .triathlonBike: return "figure.outdoor.cycle.circle"
        case .triathlonRun: return "figure.run.circle"
        }
    }
    
    var isSpeedBased: Bool {
        switch self {
        case .swim, .run, .triathlonRun, .triathlonSwim: return true
        default: return false
        }
    }
    
    var isPowerBased: Bool {
        switch self {
        case .bike, .triathlonBike: return true
        default: return false
        }
    }
}
