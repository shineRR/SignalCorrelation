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
    @IBOutlet private weak var directTimeTextField: NSTextField!
    @IBOutlet private weak var fastTimeTextField: NSTextField!
    @IBOutlet private weak var lineChartView: LineChartView!
    @IBOutlet private weak var signalComboBox: NSComboBox!
    @IBOutlet private weak var secondSignalComboBox: NSComboBox!
    
    // MARK: - Properties
    private let viewModel: ViewModelType = ViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
//        self.setupBindings()
        self.viewModel.inputs.getCorrelatedSignal(nil, nil)
    }
    
    // MARK: - Methods
    private func setupBindings() {
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
    
    private func setupUI() {
        self.signalComboBox.selectItem(at: 0)
        self.secondSignalComboBox.selectItem(at: 0)
    }
    
    private func setTime(_ direct: String, _ fast: String) {
        self.directTimeTextField.stringValue = "\(direct)ms"
        self.fastTimeTextField.stringValue = "\(fast)ms"
    }
}
