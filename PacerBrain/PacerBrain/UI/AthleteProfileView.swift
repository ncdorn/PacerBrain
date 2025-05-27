//
//  AthleteProfileView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import SwiftUI
import SwiftData

// MARK: - Sex Enumeration

// Note: Be sure your `AthleteProfile` model includes:
//   @Attribute var sex: Sex = .other
// so that this view can bind to `profile.sex`.

struct AthleteProfileView: View {
    @Bindable var profile: AthleteProfile
    @State private var isEditingProfile = false

    var body: some View {
        Form {
            // MARK: Personal Information
            Section("Personal Information") {
                TextField("Name", text: $profile.name)
                TextField("Weight (kg)",
                          value: $profile.weightKg,
                          format: .number)
                .keyboardType(.decimalPad)
                TextField("Height (cm)",
                          value: $profile.heightCm,
                          format: .number)
                .keyboardType(.decimalPad)
                Picker("Sex", selection: $profile.sex) {
                    ForEach(Sex.allCases) { sex in
                        Text(sex.rawValue.capitalized)
                            .tag(sex)
                    }
                }
                .pickerStyle(.segmented)
            }

            // MARK: Bike Power Curve Input
            PowerCurveCreator(outputCurve: profile.bikeCurve, sport: .bike)
        }
        .navigationTitle("Athlete Profile")
        .toolbar {
            editButton
        }
    }
    
    var editButton: some View {
        Button("Edit", systemImage: "pencil") {
            isEditingProfile.toggle()
        }
    }
}

// MARK: - Preview
struct AthleteProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample profile for preview purposes
        let sample = AthleteProfile(
            swimDistances: [200, 400], swimDurations: [140, 300],
            runDistances: [], runDurations: [],
            bikeOutputs: [100, 200, 300, 400, 500],
            bikeDurations: [3600, 1800, 600, 60, 30]
        )
        sample.sex = .female
        return NavigationStack {
            AthleteProfileView(profile: sample)
        }
    }
}

#Preview {
    @Previewable @State var profile = AthleteProfile(
        swimDistances: [200, 400],
        swimDurations: [140, 300],
        runDistances: [1000, 5000],
        runDurations: [160, 1200],
        bikeOutputs: [100, 200, 300, 400, 500],
        bikeDurations: [3600, 1800, 600, 60, 30])
    
    AthleteProfileView(profile: profile)
}

