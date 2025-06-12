//
//  DashboardView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//
import SwiftUI
import SwiftData

struct DashboardView: View {
    // MARK: Data In
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appSettings) private var settings
    @Environment(\.athleteProfile) private var athleteProfile
    @Query(sort: \Race.date) private var races: [Race]
    
    var upcomingRace: Race? {
        races.first(where: { $0.date > .now })
    }
    
    // MARK: Data Owned By Me
    @State private var showingEditSheet = false
    @State private var selectedRace: Race? = nil
    @State private var isCreatingNewRace = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack {
                    StatCard(title: "Critical Swim Speed", value: formattedSwimPace(speedMS: athleteProfile.criticalSwimSpeed, units: settings.unitSystem), icon: "drop.fill")
                    StatCard(title: "Bike FTP", value: "\(Int(athleteProfile.bikeFTP)) W", icon: "bicycle")
                        .padding(.vertical)
                    StatCard(title: "Run Threshold Pace", value: formattedRunPace(speedMS: athleteProfile.thresholdRunPace, units: settings.unitSystem), icon: "figure.run")
                }
                
                if let nextRace = upcomingRace {
                    VStack {
                        Text("Upcoming Race")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            selectedRace = nextRace
                        } label: {
                            RaceCardView(race: nextRace)
                        }
                        .buttonStyle(.plain)
                        .navigationDestination(item: $selectedRace) { race in
                            RaceView(for: race)
                        }
                    }
                    .padding(.top)
                }
                
                Spacer(minLength: 20)
                
                Button {
                    selectedRace = Race(units: settings.unitSystem)
                    if let selectedRace {
                        modelContext.insert(selectedRace)
                        isCreatingNewRace = true
                        showingEditSheet = true
                    }
                } label: {
                    Text("Add Your Next Race")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Card.cornerRadius * 0.75, style: .continuous))
                        .subtleShadow(opacity: 0.2)
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
            }
            .navigationTitle("Dashboard")
            .padding()
        }
    }
}
