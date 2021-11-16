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
        let N = Constants.frameCount
        var result: [Float] = []
        for n in 0..<N {
            var sum: Float = 0.0
            for m in 0..<N {
                sum += fValues[m] * sValues[(m + n + N) % N]
            }
            result.append(sum / Float(N))
        }
        
        return result
    }
    
    static func fastCorrelation(for fValues: [Float], and sValues: [Float]) -> [Float] {
        var result: [FFTFourierOutput] = []

        let fFFT = Fourier.fft(with: fValues).map({ $0.conjugate() })
        let sFFT = Fourier.fft(with: sValues)
        
        for i in 0..<fFFT.count {
            result.append(FFTFourierOutput(fFFT[i] * sFFT[i]))
        }
        
        return Fourier.restoreFFT(with: result)
    }
    
    static func autocorrelation(for values: [Float]) -> [Float] {
        var result: [Float] = []
        for n in 0..<(2 * values.count) {
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
