//
//  PreviewData.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//


// PreviewData.swift

import Foundation
import CoreLocation

struct PreviewData {
    
    static var bostonMarathon: Race {
        let race = Race(
            name: "Boston Marathon",
            date: Calendar.current.date(byAdding: .day, value: 35, to: Date())!,
            notes: "Name Speaks for itself",
            type: .run
        )
        if let gpxURL = Bundle.main.url(forResource: "boston_marathon", withExtension: "gpx"),
               let data = try? Data(contentsOf: gpxURL) {
                race.gpxData = data
            }
        if let profile = ElevationProfile(gpxData: race.gpxData!) {
            race.storedElevationProfile = profile
        }
        generateCourseSegments(for: race)
        
        race.locationName = "Boston, MA, USA"
        
        return race
    }
    static var konaRide: Race {
        let race = Race(
            name: "IMWC Ride",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!,
            notes: "The most famous bike course in triathlon",
            type: .triathlonBike
        )
        if let gpxURL = Bundle.main.url(forResource: "kona_bike", withExtension: "gpx"),
               let data = try? Data(contentsOf: gpxURL) {
                race.gpxData = data
            }
        if let profile = ElevationProfile(gpxData: race.gpxData!) {
            race.storedElevationProfile = profile
        }
        generateCourseSegments(for: race)
        
        race.locationName = "Kona, HI, USA"
        
        return race
    }
    
    static var athleteProfile: AthleteProfile {
        let profile = AthleteProfile(
            name: "Nick Dorn",
            age: 25,
            sex: .male,
            weightKg: 69.0,
            heightCm: 180.0,
            swimDistances: [50, 200, 400, 1500],
            swimDurations: [30, 145, 300, 1200],
            runDistances: [1000, 5000, 10000, 21097, 42095],
            runDurations: [160, 957, 1992, 4500, 10000],
            bikeOutputs: [521, 358, 310, 290],
            bikeDurations: [60, 300, 1200, 3600]
        )
        
        return profile
    }
    
    static func generateCourseSegments(for race: Race) {
        let generator = CourseSegmentGenerator(
            points: race.elevationProfile?.points ?? [],
            smoothingWindow: 5,
            minSegmentDistance: 300,
            maxSegmentDistance: 5000,
            climbThreshold: 2.0,
            descentThreshold: -2.0
        )

        let segments = generator.generateSegments(for: race)
        race.courseSegments = segments
    }
}
