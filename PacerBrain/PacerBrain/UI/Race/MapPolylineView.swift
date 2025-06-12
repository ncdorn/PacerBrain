//
//  MapPolylineView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//

import SwiftUI
import MapKit

struct MapPolylineView: View {
    let coordinates: [CLLocationCoordinate2D]

    @State private var cameraPosition: MapCameraPosition

    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
        if let center = coordinates.centerCoordinate {
            let region = MKCoordinateRegion(
                center: center,
                span: coordinateSpan(for: coordinates.totalDistance)
            )
            _cameraPosition = State(initialValue: .region(region))
        } else {
            _cameraPosition = State(initialValue: .automatic)
        }
    }

    var body: some View {
        Map(position: $cameraPosition) {
            if !coordinates.isEmpty {
                MapPolyline(coordinates: coordinates)
                    .stroke(.blue, lineWidth: 3)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }
}

func coordinateSpan(for totalDistance: CLLocationDistance) -> MKCoordinateSpan {
    // Very rough heuristic: span ~ distance / scalingFactor
    // These values work well for most races (e.g., 5K to Ironman)
    let degreesPerMeter = 1.0 / 111_000.0 // 1° ~ 111km
    let marginFactor = 0.8 // Adds padding

    let approxDegrees = totalDistance * degreesPerMeter * marginFactor

    return MKCoordinateSpan(latitudeDelta: approxDegrees, longitudeDelta: approxDegrees)
}

extension Array where Element == CLLocationCoordinate2D {
    var centerCoordinate: CLLocationCoordinate2D? {
        guard !isEmpty else { return nil }

        let latitudes = self.map { $0.latitude }
        let longitudes = self.map { $0.longitude }

        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!

        return CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
    }
    
    var totalDistance: CLLocationDistance {
        guard count > 1 else { return 0.0 }

        return zip(self, self.dropFirst()).reduce(0) { total, pair in
            let start = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
            let end = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
            return total + start.distance(from: end)
        }
    }
}
