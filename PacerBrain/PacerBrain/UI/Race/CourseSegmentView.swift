//
//  CourseSegmentView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//
import SwiftUI

struct CourseSegmentView: View {
    @Environment(\.appSettings) private var settings
    var segment: CourseSegment
    var isRun: Bool

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: Card.cornerRadius)
                    .fill(gradeColor(segment.averageGrade))
                    .frame(width: Card.cornerRadius)
                    .padding(.vertical, Card.cornerRadius / 2)

                
                VStack(alignment: .leading) {
                    Text(formattedRange(segment, units: settings.unitSystem))
                        .font(.headline)
                    
                    HStack {
                        Text("Length:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formattedDistance(segment.segmentDistance, units: settings.unitSystem))
                    }
                    .font(.subheadline)
                    
                    HStack {
                        Text("Avg Grade:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f%%", segment.averageGrade))
                            .foregroundColor(gradeColor(segment.averageGrade))
                    }
                    .font(.subheadline)
                    
                    if segment.isKeyClimb {
                        Text("🚩 Key Climb")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.red)
                    }
                    
                    if let speed = segment.targetSpeed, let effort = segment.targetEffort {
                        let paceText = isRun
                        ? formattedRunPace(speedMS: speed, units: settings.unitSystem)
                        : formattedBikePace(speedMS: speed, effort: effort, units: settings.unitSystem)
                        
                        HStack {
                            Text(isRun ? "Goal Pace:" : "Target Pace:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(paceText)
                        }
                        .font(.subheadline)
                    }
                    
                    if let duration = segment.targetDuration {
                        HStack {
                            Text("Target Time:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formattedDuration(duration))
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
            }
            
            if isExpanded {
                MapPolylineView(coordinates: segment.gpxPoints.map { $0.coordinates.clLocationCoordinate })
                    .frame(minHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: Card.cornerRadius))
                    .padding([.horizontal, .bottom])
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Card.cornerRadius)
                .fill(Color(.systemBackground))
                .subtleShadow()
        )
        .onLongPressGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring()) {
                isExpanded = true
            }
        }
        .onTapGesture {
            if isExpanded {
                withAnimation {
                    isExpanded = false
                }
            }
        }
        .animation(.easeInOut, value: isExpanded)
        .padding(.horizontal)
    }
    
    func formattedRange(_ segment: CourseSegment, units: UnitSystem) -> String {
        let start = segment.startDistance / 1000
        let end = (segment.startDistance + segment.segmentDistance) / 1000
        return String(format: "%.2f km – %.2f \(units.distanceUnitLabel)", start, end)
    }
}

#Preview {
    CourseSegmentsView(
        segments: PreviewData.bostonMarathon.courseSegments,
        isRun: PreviewData.bostonMarathon.type == .run || PreviewData.bostonMarathon.type == .triathlonRun
    )
}
