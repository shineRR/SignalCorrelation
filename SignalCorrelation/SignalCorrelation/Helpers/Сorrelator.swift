//
// Сorrelator.swift
// SignalCorrelation
//
// Created by Ilya Baryko on 14.11.21.
// 
//


import Foundation

final class Сorrelator {
    
    // MARK: - Static
    static func correlationCoef(for fValues: [Float], and sValues: [Float]) -> Float {
        var numerator: Float = 0.0
        var f: Float = 0.0
        var s: Float = 0.0
        for i in 0..<Constants.frameCount {
            numerator += (fValues[i] * sValues[i])
            f += pow(fValues[i], 2)
            s += pow(sValues[i], 2)
        }
        
        return numerator / (sqrt(f) * sqrt(s))
    }
    
    
    /// Correlation
    /// - Parameters:
    ///   - fValues: First signal.
    ///   - sValues: Second signal
    /// - Returns: (f * s)(t)
    static func correlation(for fValues: [Float], and sValues: [Float]) -> [Float] {
        let k = fValues.count + sValues.count - 2
        var result: [Float] = []
        for n in 0..<k {
            var sum: Float = 0.0
            for m in 0..<sValues.count {
                let index = n + m
                guard index > -1 && fValues.count > index else { continue }
                sum += fValues[index] * sValues[m]
            }
            result.append(sum)
        }
        
        return result
    }
    
    static func autocorrelation(for values: [Float]) -> [Float] {
        var result: [Float] = []
        for n in 0..<values.count {
            var sum: Float = 0.0
            for m in 0..<values.count {
                let index = n - m
                guard index > -1 && values.count > index else { continue }
                sum += values[index] * values[m]
            }
            result.append(sum)
        }
        
        return result
    }
}
