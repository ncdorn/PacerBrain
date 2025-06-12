//
//  CourseSegment.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//


import Foundation
import SwiftData

@Model
class CourseSegment {

    var id: UUID = UUID()
    var startDistance: Double      // in meters
    var segmentDistance: Double    // in meters
    var elevationChange: Double    // in meters (positive or negative)
    var averageGrade: Double       // in percent (e.g. 5.0 for 5%)
    var terrainType: TerrainType
    var isKeyClimb: Bool = false
    var gpxPoints: [GPXPoint] = []

    @Relationship var race: Race?
    
    var targetEffort: Double? = nil
    var targetSpeed: Double? = nil
    var targetDuration: TimeInterval? = nil

    var endDistance: Double {
        startDistance + segmentDistance
    }
    
    var segmentDistanceKM: Double {
        segmentDistance / 1000
    }
    
    var startDistanceKM: Double {
        startDistance / 1000
    }
    
    var endDistanceKM: Double {
        endDistance / 1000
    }

    init(
        startDistance: Double,
        gpxPoints: [GPXPoint],
        segmentDistance: Double,
        elevationChange: Double,
        averageGrade: Double,
        race: Race? = nil,
        terrainType: TerrainType = .flat
    ) {
        self.startDistance = startDistance
        self.gpxPoints = gpxPoints
        self.segmentDistance = segmentDistance
        self.elevationChange = elevationChange
        self.averageGrade = averageGrade
        self.race = race
        self.terrainType = terrainType
    }
    
    func contains(distance: Double) -> Bool {
        startDistance <= distance && distance <= endDistance
    }

}

enum TerrainType: String, Codable {
    case climb
    case descent
    case flat
}
