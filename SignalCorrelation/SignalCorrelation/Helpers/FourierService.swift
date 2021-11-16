//
// FourierService.swift
// DFT
//
// Created by Ilya Baryko on 17.10.21.
// 
//


import Foundation

final class FourierService {
    
    private static let zeroSpectrum = (amplitude: 0.0, phase: 0.0)

    // MARK: - Static Methods
    static func getFFT(with inData: [Float], invert: Bool = false) -> Spectrum {
        return Spectrum(with: Fourier.fft(with: inData, invert: invert))
    }
    
    static func getDFT(with inData: [Float]) -> Spectrum {
        var fourierData = [DFTFourierOutput]()
        for j in 0..<inData.count {
            fourierData.append(Fourier.dft(j: j, inData: inData))
        }
        return Spectrum(with: fourierData)
    }
}
