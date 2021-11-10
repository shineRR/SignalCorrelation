//
// NSRadioButton.swift
// SignalProcessing
//
// Created by Ilya Baryko on 18.09.21.
// 
//


import Cocoa

class NSRadioButton: NSButton {
    
    // MARK: - IBInspectable
    @IBInspectable var signal: Int = 0 {
        didSet {
            self.signalType = SignalType(rawValue: signal)
        }
    }
    
    // MARK: - Properties
    var signalType: SignalType!

    // MARK: - Override
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
