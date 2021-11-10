//
// ViewController.swift
// SignalCorrelation
//
// Created by Ilya Baryko on 10.11.21.
// 
//


import Cocoa
import Charts

class ViewController: NSViewController {

    // MARK: - Outlets
    @IBOutlet private weak var directTimeTextField: NSTextField!
    @IBOutlet private weak var fastTimeTextField: NSTextField!
    @IBOutlet private weak var lineChartView: LineChartView!
    @IBOutlet private weak var signalComboBox: NSComboBox!
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    // MARK: - Methods
    private func setupUI() {
        self.signalComboBox.selectItem(at: 0)
    }
    
    private func setTime(_ direct: String, _ fast: String) {
        self.directTimeTextField.stringValue = "\(direct)ms"
        self.fastTimeTextField.stringValue = "\(fast)ms"
    }
}
