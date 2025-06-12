//
//  GPXImportButton.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//

import SwiftUI
import CoreGPX
import MapKit

struct GPXImportButton: View {
    // MARK: Data In
    @Bindable var race: Race
    // MARK: Data Owned by Me
    @State private var showingFileImporter = false
    @State private var gpxFilename: String? = nil
    
    var body: some View {
        Section(header: Text("Course GPX")) {
            if race.locationName.isEmpty {
                Text("No GPX file uploaded")
                    .foregroundStyle(.tertiary)
            } else {
                Text(race.locationName)
            }
            Button {
                showingFileImporter = true
            } label: {
                Label(gpxFilename ?? "Select GPX File", systemImage: "map")
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.xml, .data, .init(filenameExtension: "gpx")!],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile = try result.get().first else { return }
                if selectedFile.startAccessingSecurityScopedResource() {
                    defer { selectedFile.stopAccessingSecurityScopedResource() }

                    let fileData = try Data(contentsOf: selectedFile)
                    race.gpxData = fileData
                    gpxFilename = selectedFile.lastPathComponent
                    populateLocationFromGPX(fileData)
                    if let profile = ElevationProfile(gpxData: race.gpxData!) {
                        race.storedElevationProfile = profile
                    }
                    generateCourseSegments()
                } else {
                    print("Failed to access file: no permission.")
                }
            } catch {
                print("Failed to import GPX: \(error.localizedDescription)")
            }
        }
    }
    
    func populateLocationFromGPX(_ data: Data) {
        guard let gpxString = String(data: data, encoding: .utf8),
              let parsed = GPXParser(withRawString: gpxString)?.parsedData(),
              let point = parsed.tracks
                .flatMap({ $0.segments })
                .flatMap({ $0.points })
                .first,
              let lat = point.latitude,
              let lon = point.longitude
        else {
            print("Failed to parse starting point from GPX")
            return
        }
        // Save lat/lon to race
        race.latitude = lat
        race.longitude = lon

        // Use CLGeocoder to look up location name
        let location = CLLocation(latitude: lat, longitude: lon)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let locality = placemark.locality ?? ""
                    let region = placemark.administrativeArea ?? ""
                    let countryCode = placemark.isoCountryCode ?? ""
                    race.locationName = [locality, region, countryCode]
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                } else {
                    race.locationName = "Lat \(lat), Lon \(lon)"
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("Location: \(race.locationName)")
        }
    }
    
    func generateCourseSegments() {
        let generator = CourseSegmentGenerator(
            points: race.elevationProfile?.points ?? [],
            smoothingWindow: 5,
            minSegmentDistance: 300,
            maxSegmentDistance: 5000,
            climbThreshold: 3.0,
            descentThreshold: -3.0
        )

        let segments = generator.generateSegments(for: race)
        race.courseSegments = segments
    }
}

