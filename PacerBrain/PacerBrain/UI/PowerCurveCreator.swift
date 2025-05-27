//
//  PowerCurveCreator.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import SwiftUI
import SwiftData

// MARK: - Root View
struct PowerCurveCreator: View {
    
    @Bindable var outputCurve: PerformanceCurve<Dimension>
    @State private var isEditingPoints = false
    @State private var isCreatingPoint = false
    @State private var newMinutesText = ""
    @State private var newSecondsText = ""
    @State private var newOutputText = ""
    @State private var commitTrigger = false // PROBABLY REMOVE THIS EVENTUALLY
    
    let distanceBased: Bool
    
    init(outputCurve: PerformanceCurve<Dimension>, sport: Sport) {
        self.outputCurve = outputCurve
        
        switch sport {
        case .bike: self.distanceBased = false
        case .swim, .run: self.distanceBased = true
        }
    }
    
    var body: some View {
        // Bike Power Curve Input
        Section(header: sectionHeader) {
            // Display static list or editable rows
            if isEditingPoints {
                ForEach($outputCurve.points, id: \.self) { $point in
                    OutputRow(point: $point, editingPoint: isEditingPoints, distanceBased)
                }
                .onDelete { offsets in
                    var copy = outputCurve.points
                    copy.remove(atOffsets: offsets)
                    outputCurve.replace(with: copy)
                }
                if isCreatingPoint {
                    VStack {
                        HStack {
                            if distanceBased {
                                TextField("Distance (m)", text: $newOutputText)
                                    .keyboardType(.numberPad)
                            } else {
                                TextField("Power (W)", text: $newOutputText)
                                    .keyboardType(.numberPad)
                            }
                            TextField("minutes", text: $newMinutesText)
                                .keyboardType(.numberPad)
                            TextField("seconds", text: $newSecondsText)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            submitButton
                            Button("Cancel") {
                                isCreatingPoint = false
                                newMinutesText = ""
                                newSecondsText = ""
                                newOutputText = ""
                            }
                        }
                    }
                } else {
                    Button("Add Power Point") {
                        isCreatingPoint = true
                        newMinutesText = ""
                        newSecondsText = ""
                        newOutputText = ""
                    }
                }
            } else {
                // Static display
                ForEach($outputCurve.points, id: \.self) { $point in
                    OutputRow(point: $point, editingPoint: isEditingPoints, distanceBased)
                }
                .onDelete { offsets in
                    var copy = outputCurve.points
                    copy.remove(atOffsets: offsets)
                    outputCurve.replace(with: copy)
                }
            }
            PerformanceCurveGraphView(curve: outputCurve)
        }
    }
    
    var submitButton: some View {
        Button("Submit") {
            if let min = Int(newMinutesText), let sec = Int(newSecondsText) {
                let duration = (min * 60) + sec
                let durationEntry = TimeInterval(duration)
                if let outputEntry = Double(newOutputText) {
                    if distanceBased {
                        let distanceEntry = outputEntry
                        let output = outputEntry * 1000.0 / durationEntry
                        let newPoint = PerformancePoint(
                            duration: durationEntry,
                            output: output,
                            unit: UnitSpeed.metersPerSecond,
                            distance: distanceEntry
                        )
                        outputCurve.insert(newPoint)
                    } else {
                        let newPoint = PerformancePoint(
                            duration: durationEntry,
                            output: outputEntry,
                            unit: UnitPower.watts
                        )
                        outputCurve.insert(newPoint)
                    }
                    print("points: \(outputCurve.points)")
                    isCreatingPoint = false
                    newMinutesText = ""
                    newSecondsText = ""
                    newOutputText = ""
                }
            }
        }
    }

    var sectionHeader: some View {
        HStack {
            Text(outputCurve.title)
            Spacer()
            editButton
                .textCase(nil)
        }
        
    }
    
    var editButton: some View {
        if !isEditingPoints {
            Button("Edit") {
                isEditingPoints = true
            }
        } else {
            Button("Done") {
                isEditingPoints = false
            }
        }
    }
}



#Preview {
    @Previewable @State var profile = AthleteProfile(
        swimDistances: [200, 400, 800],
        swimDurations: [140, 300, 620],
        runDistances: [1000, 5000, 10000],
        runDurations: [180, 1200, 2460],
        bikeOutputs: [100, 200, 300, 400, 500],
        bikeDurations: [3600, 1800, 600, 60, 30])
    
    Form {
        PowerCurveCreator(outputCurve: profile.bikeCurve, sport: .bike)
        PowerCurveCreator(outputCurve: profile.runCurve, sport: .run)
        PowerCurveCreator(outputCurve: profile.swimCurve, sport: .swim)
    }
    
    
}

