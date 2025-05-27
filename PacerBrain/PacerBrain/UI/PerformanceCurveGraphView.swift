//
//  PowerCurveGraphView.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/22/25.
//


import SwiftUI
import Charts

/// A SwiftUI view that renders a power curve as a line chart.
struct PerformanceCurveGraphView: View {
    /// The performance curve providing (duration → power) data points.
    @State private var showPoints: Bool = false
    let curve: PerformanceCurve<Dimension>
    
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
            ForEach(curve.points, id: \.self) { point in
                LineMark(
                    x: .value("Duration (s)", point.duration),
                    y: .value("Power (W)", point.output.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
                
                if showPoints {
                    PointMark(
                        x: .value("Duration (s)", point.duration),
                        y: .value("Power (W)", point.output.value)
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
struct PowerCurveGraphView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample curve for preview
        let sampleCurve = PerformanceCurve<Dimension>(
            outputs:   [400, 180, 160, 150],
            durations: [60, 120, 300, 600],
            sport: .bike
        )
        return PerformanceCurveGraphView(curve: sampleCurve)
            .frame(height: 300)
    }
}
