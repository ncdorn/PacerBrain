//
//  GPXHelpers.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//

import Foundation
import MapKit
import CoreGPX

func coordinatesFromGPX(data: Data) -> [CLLocationCoordinate2D] {
    guard let gpxString = String(data: data, encoding: .utf8),
          let parsed = GPXParser(withRawString: gpxString)?.parsedData() else {
        return []
    }

    return parsed.tracks
        .flatMap { $0.segments }
        .flatMap { $0.points }
        .compactMap { point in
            guard let lat = point.latitude, let lon = point.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
}
