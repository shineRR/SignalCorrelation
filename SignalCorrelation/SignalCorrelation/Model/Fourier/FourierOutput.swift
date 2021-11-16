//
// FourierOutput.swift
// DFT
//
// Created by Ilya Baryko on 22.10.21.
// 
//


import Foundation

class FFTFourierOutput: FourierOutput, SpectrumProtocol {
    func nullReal() -> FourierOutput {
        self.asin = .zero
        return self
    }
    
    func getAmplitude() -> Float {
        let mul = 2.0 / Float(Constants.frameCount)
        return self.hypot() * mul
    }
    
    func getPhase() -> Float {
        return -self.atan2()
    }
}

class DFTFourierOutput: FourierOutput, SpectrumProtocol {
    func getAmplitude() -> Float {
        return self.hypot()
    }
    
    func getPhase() -> Float {
        return self.atan2()
    }
}

class FourierOutput {
    
    // MARK: - Properties
    var acos: Float
    var asin: Float
    
    // MARK: - Init
    init(acos: Float = 0.0, asin: Float = 0.0) {
        self.acos = acos
        self.asin = asin
    }
    
    convenience init(_ data: FourierOutput) {
        self.init(acos: data.acos, asin: data.asin)
    }
    
    // MARK: - Methods
    func conjugate() -> FourierOutput {
        self.asin *= -1
        return self
    }
    
    func hypot() -> Float {
        return Darwin.hypot(asin, acos)
    }
    
    func atan2() -> Float {
        return Darwin.atan2(asin, acos)
    }
    
    // MARK: - Static
    static func + (_ lhs: FourierOutput, _ rhs: FourierOutput) -> FourierOutput {
        return FourierOutput(acos: lhs.acos + rhs.acos,
                             asin: lhs.asin + rhs.asin)
    }
    
    static func - (_ lhs: FourierOutput, _ rhs: FourierOutput) -> FourierOutput {
        return FourierOutput(acos: lhs.acos - rhs.acos,
                             asin: lhs.asin - rhs.asin)
    }
    
    static func * (_ lhs: FourierOutput, _ rhs: FourierOutput) -> FourierOutput {
        return FourierOutput(acos: (lhs.acos * rhs.acos - lhs.asin * rhs.asin),
                             asin: (lhs.acos * rhs.asin + lhs.asin * rhs.acos))
    }
}
