//
//  OutputRow.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/26/25.
//
import SwiftUI

struct OutputRow: View {
    @Binding var point: PerformancePoint
    @State private var minutesText: String
    @State private var secondsText: String
    @State private var powerText: String
    @State private var distanceText: String
    @State private var editingPoint: Bool
    @State private var distanceBased: Bool
    @State private var creatingPoint: Bool = false
    
    init(point: Binding<PerformancePoint>, editingPoint: Bool = false, _ distanceBased: Bool = false, _ creatingPoint: Bool = false) {
        self._point = point
        self.editingPoint = editingPoint
        self.distanceBased = distanceBased
        self.creatingPoint = creatingPoint
        _minutesText = State(initialValue: String(Int(point.wrappedValue.minutes)))
        _secondsText = State(initialValue: String(Int(point.wrappedValue.seconds)))
        _distanceText = distanceBased ? State(initialValue: String(point.wrappedValue.distance)) : State(initialValue: "0")
        _powerText    = State(initialValue: String(Int(point.wrappedValue.outputValue)))
    }
    
    var body: some View {
        if editingPoint {
            editingOutputRowView
        } else {
            displayOutputRowView
        }
    }
    
    var editingOutputRowView: some View {
        HStack {
            if distanceBased {
                TextField("Distance (m)", text: $distanceText)
                Text ("m in")
            } else {
                TextField("Power (W)", text: $powerText)
                    .keyboardType(.numberPad)
                    .onSubmit {
                        if let v = Double(powerText) {
                            point.outputValue = v
                        }
                    }
                Text("W for")
            }
            TextField("minutes", text: $minutesText)
                .keyboardType(.numberPad)
                .onSubmit {
                    if let min = Int(minutesText), let sec = Int(secondsText) {
                        let duration = TimeInterval(min * 60 + sec)
                        point.duration = duration
                    }
                }
            Text("min")
            TextField("seconds", text: $secondsText)
                .keyboardType(.numberPad)
                .onSubmit {
                    if let min = Int(minutesText), let sec = Int(secondsText) {
                        let duration = TimeInterval(min * 60 + sec)
                        point.duration = duration
                    }
                }
            Text("sec")
            
        }
    }
    
    var displayOutputRowView: some View {
        HStack {
            Spacer()
            if distanceBased {
                Text("\(Int(point.distance)) m")
                Text("in")
            } else {
                Text("\(Int(point.output.value)) W")
                Text("for")
            }
            Text(point.duration.minuteSecondString)
            Spacer()
            
        }
    }

}
