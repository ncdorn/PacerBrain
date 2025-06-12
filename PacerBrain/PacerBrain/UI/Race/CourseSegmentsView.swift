//
//  CourseSegmentsView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/2/25.
//


import SwiftUI
import SwiftData

struct CourseSegmentsView: View {
    @Environment(\.appSettings) private var settings
    let segments: [CourseSegment]
    let isRun: Bool

    @State private var selectedFilter: SegmentFilter = .all
    @State private var expandedSegment: CourseSegment? = nil

    var filteredSegments: [CourseSegment] {
        switch selectedFilter {
        case .all: return segments
        case .climbs: return segments.filter { $0.terrainType == .climb }
        case .descents: return segments.filter { $0.terrainType == .descent }
        case .keyClimbs: return segments.filter { $0.isKeyClimb }
        }
    }

    var body: some View {
        VStack {
            Picker("Filter", selection: $selectedFilter) {
                ForEach(SegmentFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical)
            
            ScrollView {
                LazyVStack {
                    ForEach(filteredSegments.sorted(by: { $0.startDistance < $1.startDistance })) { segment in
                        CourseSegmentView(segment: segment, isRun: isRun)
                            .onLongPressGesture {
                                withAnimation(.spring()) {
                                    expandedSegment = segment
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Card.cornerRadius * 0.75))
                            .subtleShadow()
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

enum SegmentFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case climbs = "Climbs"
    case descents = "Descents"
    case keyClimbs = "Key Climbs"

    var id: String { rawValue }
}
