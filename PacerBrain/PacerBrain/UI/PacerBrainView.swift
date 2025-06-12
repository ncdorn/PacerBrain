//
//  PacerBrainView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import SwiftUI
import SwiftData


struct PacerBrainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appSettings) private var settings
    @Environment(\.athleteProfile) private var athleteProfile

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "speedometer")
                }

            NavigationStack {
                RaceList()
            }
            .environmentObject(athleteProfile)
            .tabItem {
                Label("Races", systemImage: "flag.checkered")
            }

            NavigationStack {
                AthleteProfileView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingsView(settings: settings)) {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview(traits: .swiftData) {
    PacerBrainView()
        .environmentObject(PreviewData.athleteProfile)
}
