//
//  RaceList.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/1/25.
//

import SwiftUI
import SwiftData

struct RaceList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.athleteProfile) private var athleteProfile
    @Environment(\.appSettings) private var settings
    @Query private var races: [Race]

    @State private var showingEditSheet = false
    @State private var selectedRace: Race? = nil
    @State private var isCreatingNewRace = false

    var body: some View {
        List {
            ForEach(races) { race in
                Button {
                    selectedRace = race
                } label: {
                    RaceCardView(race: race)
                        .padding(.horizontal)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden) // Optional: cleaner look
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)) // Optional: full-width card style
                .swipeActions {
                    Button(role: .destructive) {
                        modelContext.delete(race)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        selectedRace = race
                        isCreatingNewRace = false
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Races")
        .navigationDestination(item: $selectedRace) { race in
            RaceView(for: race)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedRace = Race(units: settings.unitSystem)
                    if let selectedRace {
                        modelContext.insert(selectedRace)
                        isCreatingNewRace = true
                        showingEditSheet = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                if let selectedRace {
                    RaceEditView(race: selectedRace, isNew: isCreatingNewRace)
                        .onDisappear {
                            if isCreatingNewRace && selectedRace.name.isEmpty {
                                modelContext.delete(selectedRace)
                            }
                        }
                }
            }
        }
        .onAppear {
            addSampleRaces()
        }
    }
    
    func addSampleRaces() {
        let fetchDescriptor = FetchDescriptor<Race>()
        if let results = try? modelContext.fetchCount(fetchDescriptor), results == 0 {
            modelContext.insert(PreviewData.bostonMarathon)
            modelContext.insert(PreviewData.konaRide)
        }
    }
    
    func generateCourseSegments(for race: Race) {
        let generator = CourseSegmentGenerator(
            points: race.elevationProfile?.points ?? [],
            smoothingWindow: 5,
            minSegmentDistance: 0.2,
            maxSegmentDistance: 2.0,
            climbThreshold: 2.0,
            descentThreshold: -2.0
        )

        let segments = generator.generateSegments(for: race)
        race.courseSegments = segments
    }
}

#Preview(traits: .swiftData) {
    @Previewable @State var selection: Race?
    NavigationStack {
        RaceList()
            .environmentObject(PreviewData.athleteProfile)
    }
}
