//
// Spectrum.swift
// DFT
//
// Created by Ilya Baryko on 22.10.21.
// 
//


import Foundation

protocol SpectrumProtocol {
    func getAmplitude() -> Float
    func getPhase() -> Float
}

class Spectrum: Sequence {
    
    // MARK: - Properties
    var amplitude = [Float]()
    var phase = [Float]()
    var count: Int {
        return amplitude.count > phase.count ? phase.count
                                             : amplitude.count
    }
    
    // MARK: - Init
    init(with spectrum: [SpectrumProtocol] = []) {
        self.amplitude = spectrum.map({ $0.getAmplitude() })
        self.phase = spectrum.map({ $0.getPhase() })
    }
    
    // MARK: - Methods
    
    func append(_ newElement: (amplitude: Float, phase: Float)) {
        self.amplitude.append(newElement.amplitude)
        self.phase.append(newElement.phase)
    }
    
    func makeIterator() -> AnyIterator<(amplitude: Float, phase: Float)> {
        var index = 0
        return AnyIterator {
            defer { index += 1 }
            return self.count > index ? (amplitude: self.amplitude[index], phase: self.phase[index])
                                      : nil
        }
    }
}
