//
//  UIExtensions.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/27/25.
//

import SwiftUI


func formattedDuration(_ duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute, .second]
    return formatter.string(from: duration) ?? "-"
}

func formattedSwimPace(speedMS: Double, units: UnitSystem) -> String {
    var secondsPerHundred: Double {
        switch units {
        case .metric:
            return 100 / speedMS
        case .imperial:
            return 100 / (speedMS * 1.09361)
        }
    }
    
    let minutes = Int(secondsPerHundred) / 60
    let seconds = Int(secondsPerHundred) % 60
    return String(format: "%d:%02d %@", minutes, seconds, units.swimPaceUnitLabel)
}

func formattedRunPace(speedMS: Double, units: UnitSystem) -> String {
    let secondsPerUnit = units.metersPerDistanceUnit / speedMS
    let minutes = Int(secondsPerUnit) / 60
    let seconds = Int(secondsPerUnit) % 60
    return String(format: "%d:%02d %@", minutes, seconds, units.paceUnitLabel)
}

func formattedBikePace(speedMS: Double, effort: Double, units: UnitSystem) -> String {
    let convertedSpeed = units.convertSpeed(speedMS)
    return String(format: "%.1f %@ @ %.0f W", convertedSpeed, units.speedUnitLabel, effort)
}

func formattedSpeed(speedMS: Double, units: UnitSystem) -> String {
    let convertedSpeed = units.convertSpeed(speedMS)
    return String(format: "%.1f %@", convertedSpeed, units.speedUnitLabel)
}

func formattedDistance(_ meters: Double, units: UnitSystem) -> String {
    switch units {
    case .metric:
        return String(format: "%.2f km", meters / 1000)
    case .imperial:
        return String(format: "%.2f mi", meters / 1609.344)
    }
    
}

private struct AppSettingsKey: EnvironmentKey {
    static let defaultValue = AppSettingsStore(settings: AppSettings(unitSystem: .metric))
}

private struct AthleteProfileKey: EnvironmentKey {
    static let defaultValue = PreviewData.athleteProfile
}

extension EnvironmentValues {
    var appSettings: AppSettingsStore {
        get { self[AppSettingsKey.self] }
        set { self[AppSettingsKey.self] = newValue }
    }
    
    var athleteProfile: AthleteProfile {
        get { self[AthleteProfileKey.self] }
        set { self[AthleteProfileKey.self] = newValue }
    }
}

func gradeColor(_ grade: Double) -> Color {
    switch grade {
    case ..<(-8): return .purple
    case -8 ..< -5: return .green
    case -5 ..< -2: return .blue
    case -2 ..< 2: return .gray
    case 2 ..< 5: return .yellow
    case 5 ..< 8: return .orange
    default: return .red
    }
}

extension View {
    func oversizedIconSize(_ size: IconSize) -> some View {
        switch size {
        case .small: return self.font(.system(size: 32))
        case .medium: return self.font(.system(size: 48))
        case .large: return self.font(.system(size: 64))
        }
    }
    
    func subtleShadow(opacity: Double = 0.1) -> some View {
        self.shadow(color: .black.opacity(opacity), radius: 6)
    }
}

enum IconSize {
    case small
    case medium
    case large
}

struct Card {
    static let cornerRadius: CGFloat = 16
}

