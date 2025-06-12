//
//  PowerCurveGraphView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/22/25.
//


import SwiftUI
import Charts

struct PerformanceCurveGraphView: View {

    @State private var showPoints: Bool = false
    let curve: PerformanceCurve
    
    var sortedPoints: [PerformancePoint] {
        curve.points.sorted { $0.duration < $1.duration }
    }
    
    var color: Color {
        switch curve.sport {
        case .bike: return Color.pink
        case .swim: return Color.blue
        case .run: return Color.green
        }
    }
    var yAxisLabel: String {
        switch curve.sport {
        case .bike: return "Power (W)"
        case .swim, .run: return "Speed (m/s)"
        }
    }
    var body: some View {
        Chart {
            ForEach(sortedPoints, id: \.self) { point in
                LineMark(
                    x: .value("Duration (s)", point.duration),
                    y: .value("Power (W)", point.outputValue)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
                
                if showPoints {
                    PointMark(
                        x: .value("Duration (s)", point.duration),
                        y: .value("Power (W)", point.outputValue)
                    )
                    .foregroundStyle(color)
                }
            }
        }
        .chartXAxisLabel("Duration (s)")
        .chartYAxisLabel(yAxisLabel)
        .padding()
    }
}

// MARK: - Preview
// generated with chatGPT
struct PowerCurveGraphView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample curve for preview
        let sampleCurve = PerformanceCurve(
            outputs:   [400, 180, 160, 150],
            durations: [60, 120, 300, 600],
            sport: .bike
        )
        return PerformanceCurveGraphView(curve: sampleCurve)
            .frame(height: 300)
    }
}
