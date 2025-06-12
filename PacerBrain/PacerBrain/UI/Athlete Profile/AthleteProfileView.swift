//
//  AthleteProfileView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/5/25.
//
import SwiftUI

struct AthleteProfileView: View {
    @Environment(\.athleteProfile) private var profile
    @State private var isShowingEditSheet = false

    var body: some View {
        ScrollView {
            VStack {
                profileHeader
                    .padding()

                profileCard(title: "Personal Information") {
                    Spacer()
                    profileRow("Age", value: "\(profile.age)")
                    profileRow("Weight", value: "\(formatted(profile.weightKg)) kg")
                    profileRow("Height", value: "\(formatted(profile.heightCm)) cm")
                    profileRow("Sex", value: profile.sex.rawValue.capitalized)
                }
                .padding(.vertical)

                performanceCurveCard(title: "Bike Power Curve", curve: profile.bikeCurve)
                Spacer()
                performanceCurveCard(title: "Run Velocity Curve", curve: profile.runCurve)
                Spacer()
                performanceCurveCard(title: "Swim Velocity Curve", curve: profile.swimCurve)
            }
            .padding()
        }
        .navigationTitle("My Profile")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            AthleteProfileEditView(profile: profile)
        }
    }

    private var profileHeader: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .oversizedIconSize(.large)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading) {
                Text(profile.name)
                    .font(.title2.bold())
                Text("Endurance Athlete")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    func profileCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: Card.cornerRadius).fill(.ultraThinMaterial))
        .subtleShadow()
    }

    func performanceCurveCard(title: String, curve: PerformanceCurve) -> some View {
        profileCard(title: title) {
            PerformanceCurveGraphView(curve: curve)
                .frame(minHeight: 200)
        }
    }

    func profileRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    func formatted(_ number: Double) -> String {
        String(format: "%.1f", number)
    }
}

#Preview {
    AthleteProfileView()
}
