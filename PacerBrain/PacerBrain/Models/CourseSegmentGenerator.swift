//
//  CourseSegmentGenerator.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//


struct CourseSegmentGenerator {
    let points: [GPXPoint]
    let smoothingWindow: Int
    let minSegmentDistance: Double
    let maxSegmentDistance: Double
    let climbThreshold: Double
    let descentThreshold: Double

    func smoothedPoints() -> [GPXPoint] {
        guard points.count >= smoothingWindow else { return points }

        var smoothed: [GPXPoint] = []
        for i in 0..<points.count {
            let lower = max(0, i - smoothingWindow / 2)
            let upper = min(points.count - 1, i + smoothingWindow / 2)
            let window = points[lower...upper]

            let avgElevation = window.map(\.elevation).reduce(0, +) / Double(window.count)
            smoothed.append(GPXPoint(coordinates: points[i].coordinates.clLocationCoordinate, distance: points[i].distance, elevation: avgElevation))
        }
        return smoothed
    }

    func classifyGrade(from: GPXPoint, to: GPXPoint) -> TerrainType {
        let rise = to.elevation - from.elevation
        let run = (to.distance - from.distance)
        let grade = run != 0 ? (rise / run) * 100.0 : 0.0

        if grade >= climbThreshold {
            return .climb
        } else if grade <= descentThreshold {
            return .descent
        } else {
            return .flat
        }
    }

    func generateSegments(for race: Race) -> [CourseSegment] {
        let smoothed = smoothedPoints()
        guard smoothed.count > 1 else { return [] }

        var segments: [CourseSegment] = []
        var startIdx = 0
        var currentType = classifyGrade(from: smoothed[0], to: smoothed[1])

        var i = 2
        while i < smoothed.count {
            let thisType = classifyGrade(from: smoothed[i - 1], to: smoothed[i])
            let segmentDistance = smoothed[i].distance - smoothed[startIdx].distance

            let isLastPoint = i == smoothed.count - 1
            let terrainChanged = thisType != currentType

            if terrainChanged && segmentDistance < minSegmentDistance {
                // Wait until we either hit min distance or settle into new terrain
                i += 1
                continue
            }

            if terrainChanged || segmentDistance >= maxSegmentDistance || isLastPoint {
                let start = smoothed[startIdx]
                let end = smoothed[i]
                let totalDist = end.distance - start.distance
                let elevationChange = end.elevation - start.elevation
                let avgGrade = (elevationChange / (totalDist)) * 100.0
                
                let segmentType = classifyGrade(from: start, to: end)
                
                let isKeyClimb = segmentType==TerrainType.climb && totalDist >= 500 || avgGrade >= 5.0

                if totalDist >= minSegmentDistance || isLastPoint {
                    let segment = CourseSegment(
                        startDistance: start.distance,
                        gpxPoints: Array(smoothed[startIdx..<i]),
                        segmentDistance: totalDist,
                        elevationChange: elevationChange,
                        averageGrade: avgGrade,
                        race: race,
                        terrainType: segmentType
                    )
                    segment.isKeyClimb = isKeyClimb
                    segments.append(segment)
                    startIdx = i
                    currentType = thisType
                }
            }

            i += 1
        }

        return segments
    }
}
