//
//  RaceCardView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//


import SwiftUI
import MapKit

struct RaceCardView: View {
    @Environment(\.appSettings) private var settings
    let race: Race
    var showMap: Bool = true

    var body: some View {
        VStack {
            HStack {
                Image(systemName: race.type.iconName)
                Text(race.name)
                    .font(.title3.bold())
                    .lineLimit(1)
                Spacer()
                Text(race.date, style: .date)
            }

            HStack {
                Text(formattedDistance(race.totalDistance, units: settings.unitSystem))
                Spacer()
                Text(race.type.rawValue)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            if !(race.gpxData == nil) && showMap {
                let coordinates = coordinatesFromGPX(data: race.gpxData!)
                MapPolylineView(coordinates: coordinates)
                    .frame(minHeight: 120, maxHeight: 240)
                    .cornerRadius(Card.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Card.cornerRadius)
                            .stroke(Color.gray.opacity(0.2))
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Card.cornerRadius, style: .continuous))
        .subtleShadow(opacity: 0.2) // slightly more defined than the rest of the UI
    }
}

#Preview {
    @Previewable let race = PreviewData.konaRide
    RaceCardView(race: race)
        .padding()
}
