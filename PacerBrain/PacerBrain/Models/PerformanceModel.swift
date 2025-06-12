//
//  PerformanceModel.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/27/25.
//
// created with CharGPT o3

import Foundation
import Accelerate

// MARK: - Output Models

struct PowerLawModel: PerformanceModel {
    let S: Double
    let E: Double

    func output(at t: TimeInterval) -> Double {
        S * pow(t, -E)
    }
}

struct CriticalPowerModel: PerformanceModel {
    let cp: Double      // Critical Power (W)
    let wp: Double      // W′ (J)
    let k: Double       // curvature constant (s)

    func output(at t: TimeInterval) -> Double {
        cp + wp / (t + k)
    }
}

struct SwimDecayModel: PerformanceModel {
    let css: Double     // Critical Swim Speed (m/s)
    let delta: Double
    let k: Double

    func output(at t: TimeInterval) -> Double {
        css - delta * (1 - exp(-k * t))
    }
}

// MARK: - Fitting Utility

struct PerformanceCurveFitter {

    // -------- Power Law: log(v) = log(S) - E * log(t) --------------
    static func fitPowerLaw(from points: [PerformancePoint]) -> PowerLawModel? {
        let valid = points.filter { $0.unitSymbol == "m/s" || $0.unitSymbol == "W" }
        guard valid.count >= 2 else { return nil }
        
        let logT = valid.map { log($0.duration) }
        let logV = valid.map { log($0.outputValue) }
        
        let n = Double(logT.count)
        let sumX = logT.reduce(0, +)
        let sumY = logV.reduce(0, +)
        let sumXY = zip(logT, logV).map(*).reduce(0, +)
        let sumX2 = logT.map { $0 * $0 }.reduce(0, +)
        
        let meanX = sumX / n
        let meanY = sumY / n
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
        let intercept = meanY - slope * meanX
        
        let S = exp(intercept)
        let E = -slope
        
        return PowerLawModel(S: S, E: E)
    }

    // -------- Critical Power 3-parameter model fit ------------------
    // P(t) = CP + W′ / (t + k)  → Nonlinear least squares
    static func fit3PModel(from points: [PerformancePoint]) -> CriticalPowerModel? {
        let valid = points.filter { $0.unitSymbol == "W" }
        guard valid.count >= 3 else { return nil }

        // Naive grid search (replace with Levenberg–Marquardt or SwiftFusion later)
        let cpRange = stride(from: 100.0, through: 400.0, by: 10.0)
        let wpRange = stride(from: 5000.0, through: 25000.0, by: 1000.0)
        let kRange  = stride(from: 1.0, through: 60.0, by: 2.0)

        var bestParams: (Double, Double, Double)? = nil
        var minError = Double.infinity

        for cp in cpRange {
            for wp in wpRange {
                for k in kRange {
                    let error = valid.reduce(0.0) { sum, pt in
                        let predicted = cp + wp / (pt.duration + k)
                        return sum + pow(predicted - pt.outputValue, 2)
                    }
                    if error < minError {
                        minError = error
                        bestParams = (cp, wp, k)
                    }
                }
            }
        }
        if let (cp, wp, k) = bestParams {
            return CriticalPowerModel(cp: cp, wp: wp, k: k)
        }
        return nil
    }

    // -------- Swim: v(t) = CSS - delta * (1 - exp(-k * t)) ---------
    static func fitSwimModel(from points: [PerformancePoint]) -> SwimDecayModel? {
        let valid = points.filter { $0.unitSymbol == "m/s" }
        guard valid.count >= 3 else { return nil }

        let css = valid.max(by: { $0.duration < $1.duration })?.outputValue ?? 1.3
        var best: (delta: Double, k: Double)? = nil
        var minError = Double.infinity

        for delta in stride(from: 0.01, through: 0.5, by: 0.01) {
            for k in stride(from: 0.001, through: 0.01, by: 0.001) {
                let error = valid.reduce(0.0) { sum, pt in
                    let v = css - delta * (1 - exp(-k * pt.duration))
                    return sum + pow(v - pt.outputValue, 2)
                }
                if error < minError {
                    minError = error
                    best = (delta, k)
                }
            }
        }

        if let best = best {
            return SwimDecayModel(css: css, delta: best.delta, k: best.k)
        }
        return nil
    }
}

// MARK: - Protocol

protocol PerformanceModel {
    func output(at duration: TimeInterval) -> Double
}
