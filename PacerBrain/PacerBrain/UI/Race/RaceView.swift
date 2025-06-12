//
//  RaceView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/27/25.
//
import SwiftUI
import MapKit
import CoreGPX

struct RaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.athleteProfile) private var athleteProfile
    @Environment(\.appSettings) private var settings
    
    // MARK: Data Owned by ME
    @State private var showingEditSheet = false
    @Bindable var localRace: Race
    @State private var isOptimizing = false
    @State private var scrollTarget: String?
    
    init(for race: Race) {
        self.localRace = race
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.vertical) {
                    raceHeader
                    
                    raceDetails
                    
                    pacingPlanCTAButton
                        .onChange(of: localRace.pacingIsOptimized) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    
                    // Notes
                    if !localRace.notes.isEmpty {
                        InfoCard(title: "Notes", value: localRace.notes, icon: "note.text")
                    }
                    
                    // Course Content
                    courseMap
                    
                    
                }
                .padding()
            }
            .onChange(of: scrollTarget) {
                if let target = scrollTarget {
                    withAnimation {
                        proxy.scrollTo(target, anchor: .top)
                    }
                    scrollTarget = nil
                }
            }
            .navigationTitle(localRace.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    RaceEditView(race: localRace, isNew: false)
                }
            }
        }
    }
    
    @ViewBuilder
    var courseMap: some View {
        if let gpxData = localRace.gpxData {
            let coordinates = coordinatesFromGPX(data: gpxData)
            
            if !coordinates.isEmpty {
                VStack(alignment: .leading) {
                    Label("Course Map", systemImage: "map")
                        .font(.headline)
                    MapPolylineView(coordinates: coordinates)
                        .frame(height: 250)
                        .cornerRadius(Card.cornerRadius * 0.75)
                }
                .padding(.vertical)
                
                if let profile = ElevationProfile(gpxData: gpxData), !profile.points.isEmpty {
                    VStack(alignment: .leading) {
                        Label("Elevation Profile", systemImage: "mountain.2.fill")
                            .font(.headline)
                        ElevationProfileView(profile: profile, segments: localRace.courseSegments)
                    }
                }
                
                VStack(alignment: .leading) {
                    Label("Course Segments", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                        .font(.headline)
                    CourseSegmentsView(
                        segments: localRace.courseSegments,
                        isRun: localRace.type == .run || localRace.type == .triathlonRun
                    )
                }
                .id("courseSegments")
            } else {
                GPXImportButton(race: localRace)
            }
        }
    }
    
    var pacingPlanCTAButton: some View {
        VStack(spacing: Spacing.vertical) {
            if isOptimizing {
                ProgressView("Optimizing pacing...")
            } else {
                Button {
                    generatePacingPlan()
                } label: {
                    Label("Generate Pacing Plan", systemImage: "bolt.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Card.cornerRadius * 0.75))
                }
                .disabled(isOptimizing)
            }

            if localRace.pacingIsOptimized {
                VStack(spacing: Spacing.vertical) {
                    RaceSummaryMetricsView(
                        raceType: localRace.type,
                        totalTime: localRace.totalTime,
                        averagePowerOrPace: localRace.averagePowerOrPace,
                        averageSpeed: formattedSpeed(speedMS: localRace.averageSpeed, units: settings.unitSystem)
                    )

                    Button {
                        scrollTarget = "courseSegments"
                    } label: {
                        Label("View Pacing Plan", systemImage: "figure.run")
                            .font(.subheadline)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: Card.cornerRadius).fill(.ultraThinMaterial))
    }
    
    var raceDetails: some View {
        HStack(spacing: Spacing.horizontal) {
            InfoCard(title: "Race Type", value: localRace.type.rawValue, icon: localRace.type.iconName)
            InfoCard(title: "Location", value: localRace.locationName.isEmpty ? "Not specified" : localRace.locationName, icon: "mappin.and.ellipse")
        }
    }
    
    var raceHeader: some View {
        HStack(spacing: Spacing.horizontal) {
            Image(systemName: localRace.type.iconName)
                .oversizedIconSize(.large)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(localRace.name)
                    .font(.title2.bold())
                Text(localRace.date.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    func generatePacingPlan() {
        isOptimizing = true
        
        Task {
            guard let model = athleteProfile.performanceModel(for: localRace.type) else { return }
            
            var pacingPlan = PacingOptimizer(
                raceType: localRace.type,
                segments: localRace.courseSegments,
                model: model
            )
            
            pacingPlan.optimize()
            
            localRace.pacingIsOptimized = true
            isOptimizing = false
        }
    }
}

fileprivate struct Spacing {
    static let vertical: CGFloat = 16
    static let horizontal: CGFloat = 16
}

#Preview {
    RaceView(for: PreviewData.konaRide)
        .environmentObject(PreviewData.athleteProfile)
}

