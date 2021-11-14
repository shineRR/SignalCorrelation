//
// Constants.swift
// SignalProcessing
//
// Created by Ilya Baryko on 22.09.21.
// 
//


import Foundation

typealias SignalFormula = ((Float) -> Float)
typealias SignalComponent = (formula: SignalFormula, type: SignalType)

enum SignalType: Int {
    case sine = 0
    case impulse
    case triangle
    case sawtooth
    case whitenoise
    
    static subscript(signal: SignalType) -> SignalComponent {
        switch signal {
        case .sine:
            return (Constants.sine, signal)
        case .impulse:
            return (Constants.impulse, signal)
        case .triangle:
            return (Constants.triangle, signal)
        case .whitenoise:
            return (Constants.whitenoise, signal)
        case.sawtooth:
            return (Constants.sawtooth, signal)
        }
    }
}

struct Constants {
    static var duty = Float.pi
    static let doublePi = 2 * Float.pi
    static let frameCount = 512
    
    static let sine = { (phase: Float) -> Float in
        return sin(phase)
    }

    static let whitenoise = { (phase: Float) -> Float in
        return Float.random(in: -1.0...1.0)
    }

    static let sawtooth = { (phase: Float) -> Float in
        return 1.0 - 2.0 * (phase * (1.0 / doublePi))
    }

    static let impulse = { (phase: Float) -> Float in
        return phase <= duty ? 1.0 : -1.0
    }

    static let triangle = { (phase: Float) -> Float in
        var value = (2.0 * (phase * (1.0 / doublePi))) - 1.0
        if value < 0.0 {
            value = -value
        }
        return 2.0 * (value - 0.5)
    }
}
