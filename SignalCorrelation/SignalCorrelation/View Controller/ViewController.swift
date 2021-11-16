//
// ViewController.swift
// SignalCorrelation
//
// Created by Ilya Baryko on 10.11.21.
// 
//


import RxCocoa
import RxSwift
import Charts

class ViewController: NSViewController {

    // MARK: - Outlets
    @IBOutlet private weak var typeSegmentedControl: NSSegmentedControl!
    @IBOutlet private weak var directTimeTextField: NSTextField!
    @IBOutlet private weak var fastTimeTextField: NSTextField!
    @IBOutlet private weak var fLineChartView: LineChartView!
    @IBOutlet private weak var sLineChartView: LineChartView!
    @IBOutlet private weak var fastLineChartView: LineChartView!
    @IBOutlet private weak var lineChartView: LineChartView!
    @IBOutlet private weak var processButton: NSButton!
    
    /// First signal
    @IBOutlet private weak var signalComboBox: NSComboBox!
    @IBOutlet private weak var fAmplitudeTextField: NSTextField!
    @IBOutlet private weak var fFreqTextField: NSTextField!
    @IBOutlet private weak var fPhaseTextField: NSTextField!
    
    /// Second signal
    @IBOutlet private weak var secondSignalComboBox: NSComboBox!
    @IBOutlet private weak var sAmplitudeTextField: NSTextField!
    @IBOutlet private weak var sFreqTextField: NSTextField!
    @IBOutlet private weak var sPhaseTextField: NSTextField!
    
    // MARK: - Properties
    private let viewModel: ViewModelType = ViewModel()
    private let disposeBag = DisposeBag()
    private var isAutocorrelation: Bool {
        return self.typeSegmentedControl.selectedSegment == 1
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupBindings()
    }
    
    // MARK: - Methods
    private func setupBindings() {
        self.processButton.rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.processCorrelation()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs
            .firstSignal
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                self.fLineChartView.data = data
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs
            .secondSignal
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { data in
                self.sLineChartView.data = data
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs
            .directLineChartData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.lineChartView.data = data
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs
            .fastLineChartData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.fastLineChartView.data = data
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs
            .directTime
            .observe(on: MainScheduler.instance)
            .bind(to: self.directTimeTextField.rx.stringValue)
            .disposed(by: self.disposeBag)
        
        self.viewModel.outputs
            .fastTime
            .observe(on: MainScheduler.instance)
            .bind(to: self.fastTimeTextField.rx.stringValue)
            .disposed(by: self.disposeBag)
    }
    
    private func processCorrelation() {
        guard let fType = SignalType(rawValue: self.signalComboBox.indexOfSelectedItem) else { return }
        var sSignal: Signal?
        let fSignal = self.createSignal(with: SignalType[fType], amplitude: self.fAmplitudeTextField.floatValue,
                                        freq: self.fFreqTextField.floatValue,
                                        phase: self.fPhaseTextField.floatValue)
        if let sType = SignalType(rawValue: self.secondSignalComboBox.indexOfSelectedItem) {
            sSignal = self.createSignal(with: SignalType[sType], amplitude: self.sAmplitudeTextField.floatValue,
                                        freq: self.sFreqTextField.floatValue,
                                        phase: self.sPhaseTextField.floatValue)
        }
        
        self.viewModel.inputs.getCorrelatedSignal(fSignal, sSignal, isAutocorrelation: self.isAutocorrelation)
    }
    
    private func createSignal(with component: SignalComponent, amplitude: Float, freq: Float, phase: Float) -> Signal {
        return Signal(signal: component, amplitude: amplitude,
                      frequency: freq, currentPhase: phase)
    }
    
    private func setupChart(with lineChartView: LineChartView, shouldDisableLeft: Bool = false) {
        lineChartView.leftAxis.enabled = !shouldDisableLeft
        lineChartView.rightAxis.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.doubleTapToZoomEnabled = false
        
        let yAxis = lineChartView.leftAxis
        yAxis.drawGridLinesEnabled = false
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.valueFormatter = DefaultAxisValueFormatter(decimals: 100)
        
        let xAxis = lineChartView.xAxis
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLabelsEnabled = false
        xAxis.labelPosition = .bottom
        
//        self.lineChartView.animate(xAxisDuration: 1.0, easingOption: .linear)
    }
    
    private func setData(with set: LineChartDataSet) {
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        self.lineChartView.data = data
    }
    
    private func setupUI() {
        self.signalComboBox.selectItem(at: 0)
        self.secondSignalComboBox.selectItem(at: 0)
        self.setupChart(with: self.fLineChartView)
        self.setupChart(with: self.sLineChartView)
        self.setupChart(with: self.fastLineChartView, shouldDisableLeft: true)
        self.setupChart(with: self.lineChartView, shouldDisableLeft: true)
    }
}
