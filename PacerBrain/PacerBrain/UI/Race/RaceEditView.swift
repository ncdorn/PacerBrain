//
//  RaceEditView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/1/25.
//


import SwiftUI
import UniformTypeIdentifiers

struct RaceEditView: View {
    // MARK: Data In
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Data Owned By Me
    
    @Bindable var race: Race
    let isNew: Bool

    var body: some View {
        Form {
            Section(header: Text("Race Details")) {
                TextField("Name", text: $race.name)
                DatePicker("Date", selection: $race.date, displayedComponents: .date)
                Picker("Race Type", selection: $race.type) {
                        ForEach(RaceType.allCases) { type in
                            Label(type.rawValue, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                TextEditor(text: $race.notes)
                    .frame(height: 120)
            }
            GPXImportButton(race: race)
        }
        .navigationTitle(isNew ? "New Race" : "Edit Race")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Cancel button on the leading side
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            // Save button on the trailing side
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if isNew {
                        modelContext.insert(race)
                    }
                    dismiss()
                }
                .disabled(race.name.isEmpty)
            }
        }
    }
}
