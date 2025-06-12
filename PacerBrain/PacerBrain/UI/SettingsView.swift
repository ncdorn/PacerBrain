//
//  SettingsView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/4/25.
//


import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettingsStore

    var body: some View {
        Form {
            Section(header: Text("Units")) {
                Picker("Unit System", selection: $settings.unitSystem) {
                    ForEach(UnitSystem.allCases, id: \.self) { system in
                        Text(system.rawValue).tag(system)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Settings")
    }
}
