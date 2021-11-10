//
// NSViewController+Extensions.swift
// SignalProcessing
//
// Created by Ilya Baryko on 18.09.21.
// 
//


import Cocoa

// MARK: - NSViewController
extension NSViewController {
    func changeRadionButtonState(for buttons: [NSRadioButton], to state: NSButton.StateValue) {
        buttons.forEach { $0.state = state }
    }
        
    func selectedSignals(for buttons: [NSRadioButton]) -> [SignalComponent] {
        return buttons
            .filter({ $0.state == .on })
            .map({ SignalType[$0.signalType] })
    }
}
