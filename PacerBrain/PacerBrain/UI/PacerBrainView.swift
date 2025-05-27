//
//  PacerBrainView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import SwiftUI
import SwiftData

// MARK: - Root View
struct PacerBrainView: View {
    /// Selected item in the sidebar
    @State private var selection: SidebarItem?
    @State private var sampleProfile = AthleteProfile(
            name: "Nick",
            weightKg: 70,
            heightCm: 175,
            swimDistances: [100,200,400],
            swimDurations: [60,120,300],
            runDistances:  [1000,5000],
            runDurations:  [240,1200],
            bikeOutputs:   [150,200,250],
            bikeDurations: [60, 120, 300]
        )

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // ----- Sidebar --------------------------------------------------
            List(SidebarItem.allCases, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.icon)
                }
            }
            .navigationTitle("PacerBrain")
        } detail: {
            // ----- Detail Pane ---------------------------------------------
            switch selection {
            case .dashboard:    DashboardView()
            case .races:        RaceChooserView()
            case .profile:      AthleteProfileView(profile: sampleProfile)
            case .settings:     SettingsView()
            default:            Text("Select an item from the sidebar.")
            }
        }
    }
}

// MARK: - Sidebar Routing Enum
private enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard
    case races
    case profile
    case settings

    var id: Self { self }

    /// Human-readable title
    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .races:     "Races"
        case .profile:   "Profile"
        case .settings:  "Settings"
        }
    }

    /// SFSymbol for sidebar label
    var icon: String {
        switch self {
        case .dashboard: "speedometer"
        case .races:     "flag.checkered"
        case .profile:   "person.crop.circle"
        case .settings:  "gearshape"
        }
    }
}

#Preview {
    PacerBrainView()
}
