//
// Signal.swift
// SignalProcessing
//
// Created by Ilya Baryko on 18.09.21.
// 
//


import Foundation

protocol SignalModulation {
    func getFrequency() -> Float
    func getValue(for phase: Float) -> Float
    func getValue() -> Float
    func getValueAM() -> Float
    func getIncrementPhase() -> Float
    func incrementPhase()
}

final class Signal: SignalModulation {

    // MARK: - Properties
    private var type: SignalType
    private var formula: SignalFormula
    private var currentPhase: Float
    private var frequency: Float
    private var amplitude: Float
    private var incrementPhaseValue: Float
    
    // MARK: - Init
    init(signal: SignalComponent, amplitude: Float, frequency: Float, currentPhase: Float) {
        self.type = signal.type
        self.formula = signal.formula
        self.frequency = frequency
        self.amplitude = amplitude
        self.currentPhase = currentPhase
        
        self.incrementPhaseValue = ConstantSignal.doublePi / Float(ConstantSignal.frameCount) * frequency
    }
    
    // MARK: - Methods
    func getFrequency() -> Float {
        return self.frequency
    }
    
    func getValue(for phase: Float) -> Float {
        return formula(phase) * self.amplitude
    }
    
    func getValueAM() -> Float {
        return formula(self.currentPhase)
    }
    
    func getValue() -> Float {
        return formula(self.currentPhase) * self.amplitude
    }
    
    func getIncrementPhase() -> Float {
        return self.incrementPhaseValue
    }
    
    func incrementPhase() {
        self.currentPhase += self.incrementPhaseValue
        if self.currentPhase >= ConstantSignal.doublePi {
            self.currentPhase -= ConstantSignal.doublePi
        }
        if self.currentPhase < 0.0 {
            self.currentPhase += ConstantSignal.doublePi
        }
    }
}
