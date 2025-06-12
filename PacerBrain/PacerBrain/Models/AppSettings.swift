//
//  AppSettings.swift
//  PacerBrain
//
//  Created by ChatGPT 4o
//  Prompt: make app settings persist and be accessible across all views
//

import Foundation
import SwiftData

@Model
class AppSettings {
    var unitSystem: UnitSystem

    init(unitSystem: UnitSystem = .metric) {
        self.unitSystem = unitSystem
    }
}

@Observable
class AppSettingsStore {
    var settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    var unitSystem: UnitSystem {
        get { settings.unitSystem }
        set { settings.unitSystem = newValue }
    }
}
