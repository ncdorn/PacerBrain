//
//  PacerBrainApp.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/21/25.
//

import SwiftUI
import SwiftData

@main
struct PacerBrainApp: App {

    var body: some Scene {
        WindowGroup {
            Group {
                PacerBrainView()
                    .modelContainer(for: [
                        AthleteProfile.self,
                        PerformanceCurve.self,
                        PerformancePoint.self,
                        Race.self,
                        AppSettings.self
                    ])
            }
        }
    }
}
