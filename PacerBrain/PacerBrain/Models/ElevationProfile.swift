//
//  ElevationPoint.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//


import Foundation
import CoreGPX
import CoreLocation

struct GPXPoint: Identifiable, Codable, Hashable {
    let id: UUID
    let coordinates: CodableCoordinate
    let distance: Double  // in meters
    let elevation: Double // in meters
    var segmentGrade: Double?
    
    var distanceKM: Double {
        distance / 1000.0
    }
    
    init(id: UUID = UUID(), coordinates: CLLocationCoordinate2D, distance: Double, elevation: Double) {
        self.id = id
        self.coordinates = CodableCoordinate(coordinates)
        self.distance = distance
        self.elevation = elevation
    }
}

// chatGPT "how to make CLLocationCoordinate codable"
struct CodableCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

struct ElevationProfile: Identifiable, Codable {
    let id: UUID
    let points: [GPXPoint]

    // MARK: init
    init(id: UUID = UUID(), points: [GPXPoint]) {
        self.id = id
        self.points = points
    }

    // optional init
    init?(gpxData: Data) {
        guard let gpxString = String(data: gpxData, encoding: .utf8),
              let parsed = GPXParser(withRawString: gpxString)?.parsedData() else {
            return nil
        }
        
        let rawPoints = parsed.tracks
            .flatMap(\.segments)
            .flatMap(\.points)
            .compactMap { point -> (CLLocationCoordinate2D, Double)? in
                guard let lat = point.latitude,
                      let lon = point.longitude,
                      let ele = point.elevation else { return nil }
                return (CLLocationCoordinate2D(latitude: lat, longitude: lon), ele)
            }
        
        var result: [GPXPoint] = []
        var totalDistance = 0.0
        var previousLocation: CLLocation?
        
        for (coord, elevation) in rawPoints {
            let current = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            if let prev = previousLocation {
                totalDistance += prev.distance(from: current)
            }
            result.append(GPXPoint(coordinates: coord, distance: totalDistance, elevation: elevation))
            previousLocation = current
        }
        
        self.init(points: result)
    }

    var totalAscent: Double {
        zip(points, points.dropFirst())
            .map { max($1.elevation - $0.elevation, 0) }
            .reduce(0, +)
    }

    var maxElevation: Double? {
        points.map(\.elevation).max()
    }
}
