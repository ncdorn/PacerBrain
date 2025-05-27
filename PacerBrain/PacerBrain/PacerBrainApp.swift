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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            PacerBrainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
