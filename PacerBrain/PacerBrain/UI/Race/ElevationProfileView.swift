//
//  ElevationProfileView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//

import SwiftUI
import Charts


struct ElevationProfileView: View {
    let profile: ElevationProfile      // all points, ordered by distance
    let segments: [CourseSegment]      // same order, non-overlapping


    var segmentedSeries: [SegmentedElevation] {
        segments.map { segment in
            let pointsInSegment = profile.points.filter {
                $0.distance >= segment.startDistance && $0.distance <= segment.endDistance
            }
            return SegmentedElevation(segment: segment, points: pointsInSegment)
        }
    }

    var body: some View {
        let maxDist = profile.points.map(\.distanceKM).max() ?? .zero
        let maxElev = profile.points.map(\.elevation).max() ?? .zero

        Chart {
            // Clean overlay line
            ForEach(profile.points) { point in
                LineMark(
                    x: .value("Distance", point.distanceKM),
                    y: .value("Elevation", point.elevation)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.ultraThinMaterial)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartXScale(domain: 0...maxDist)
        .chartYScale(domain: 0...(maxElev * 1.1))
        .chartXAxisLabel("Distance (km)")
        .chartYAxisLabel("Elevation (m)")
        .frame(height: 220)
        .padding(.horizontal)
    }
    
//    func segmentMark(from series: SegmentedElevation) -> some View? {
//
//    }

    // Colour palette for segment grade (change as you like)
    private func gradeColor(_ grade: Double) -> Color {
        switch grade {
        case ..<(-8):      return .purple
        case -8 ..< -5:    return .green
        case -5 ..< -2:    return .blue
        case -2 ..<  2:    return .clear        // transparent / no fill
        case  2 ..<  5:    return .yellow
        case  5 ..<  8:    return .orange
        default:           return .red
        }
    }
}

/// Helper models
struct SegmentedElevation: Identifiable {
    let id = UUID()
    let segment: CourseSegment
    let points: [GPXPoint]
}

#Preview {
    let points = PreviewData.bostonMarathon.storedElevationProfile!
    let segments = PreviewData.bostonMarathon.courseSegments
    ElevationProfileView(profile: points, segments: segments)
}
