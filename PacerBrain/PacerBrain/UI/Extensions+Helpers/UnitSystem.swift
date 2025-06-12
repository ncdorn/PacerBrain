//
//  Units.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 6/3/25.
//


enum UnitSystem: String, Codable, CaseIterable {
    case metric
    case imperial

    var paceUnitLabel: String {
        switch self {
        case .metric: return "min/km"
        case .imperial: return "min/mi"
        }
    }
    
    var swimPaceUnitLabel: String {
        switch self {
        case .metric: return "/100m"
        case .imperial: return "/100yd"
        }
    }

    var speedUnitLabel: String {
        switch self {
        case .metric: return "km/h"
        case .imperial: return "mi/h"
        }
    }

    var metersPerDistanceUnit: Double {
        switch self {
        case .metric: return 1000.0
        case .imperial: return 1609.34
        }
    }

    func convertSpeed(_ speed: Double) -> Double {
        switch self {
        case .metric: return speed * 3.6        // m/s → km/h
        case .imperial: return speed * 2.23694  // m/s → mi/h
        }
    }
    
    var distanceUnitLabel: String {
        switch self {
        case .metric: return "km"
        case .imperial: return "mi"
        }
    }
}
