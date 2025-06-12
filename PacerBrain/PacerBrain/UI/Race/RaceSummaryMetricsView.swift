//
//  MetricCardView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//
import SwiftUI

struct RaceSummaryMetricsView: View {
    let raceType: RaceType
    let totalTime: TimeInterval
    let averagePowerOrPace: String
    let averageSpeed: String

    var body: some View {
        VStack {
            MetricCardView(label: "Total Time", value: formattedDuration(totalTime))
            MetricCardView(label: averageLabel, value: averagePowerOrPace)
            MetricCardView(label: "Avg Speed", value: averageSpeed)
        }
        .padding(.horizontal)
    }
    
    private var averageLabel: String {
        switch raceType {
        case .bike, .triathlonBike:
            return "Average Power"
        case .run, .triathlonRun:
            return "Average Pace"
        case .swim, .triathlonSwim:
            return "Average Pace"
        }
    }
}


struct MetricCardView: View {
    let label: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(Card.cornerRadius)
    }
}


