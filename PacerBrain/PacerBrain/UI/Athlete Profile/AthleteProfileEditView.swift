//
//  AthleteProfileView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import SwiftUI
import SwiftData

struct AthleteProfileEditView: View {
    @Bindable var profile: AthleteProfile
    @State private var isEditingProfile = false

    var body: some View {
        Form {
            Section("Personal Information") {
                HStack {
                    fieldText("Name")
                    TextField("Name", text: $profile.name)
                }
                HStack {
                    fieldText("Age")
                    TextField("Age", value: $profile.age, format: .number)
                }
                HStack {
                    fieldText("Weight (kg)")
                    TextField("Weight (kg)",
                              value: $profile.weightKg,
                              format: .number)
                    .keyboardType(.decimalPad)
                }
                HStack {
                    fieldText("Height (cm)")
                    TextField("Height (cm)",
                              value: $profile.heightCm,
                              format: .number)
                    .keyboardType(.decimalPad)
                }
                    Picker("Sex", selection: $profile.sex) {
                        ForEach(Sex.allCases) { sex in
                            Text(sex.rawValue.capitalized)
                                .tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                
            }

            PowerCurveCreator(outputCurve: profile.bikeCurve, sport: .bike)
            PowerCurveCreator(outputCurve: profile.runCurve, sport: .run)
            PowerCurveCreator(outputCurve: profile.swimCurve, sport: .swim)
        }
        .navigationTitle("Athlete Profile")
        .toolbar {
            editButton
        }
    }
    
    func fieldText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            isEditingProfile.toggle()
        }
    }
}



#Preview {
    AthleteProfileEditView(profile: PreviewData.athleteProfile)
}

