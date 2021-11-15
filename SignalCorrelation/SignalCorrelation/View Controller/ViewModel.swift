//
// ViewModel.swift
// SignalCorrelation
//
// Created by Ilya Baryko on 14.11.21.
// 
//


import Foundation
import RxSwift
import RxRelay
import Charts

protocol ViewModelType {
    var inputs: ViewModelInputs { get }
    var outputs: ViewModelOutputs { get }
}

protocol ViewModelInputs {
    func getCorrelatedSignal(_ firstSignal: Signal, _ secondSignal: Signal?, isAutocorrelation: Bool)
}

protocol ViewModelOutputs {
    var firstSignal: Observable<[Float]> { get }
    var secondSignal: Observable<[Float]> { get }
    var correlatedSignal: Observable<[Float]> { get }
    var lineChartData: Observable<LineChartData> { get }
    var directTime: Observable<String> { get }
    var fastTime: Observable<String> { get }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    // MARK: - Consts
    enum Consts {
        static let firstSignalTitle = "First"
        static let secondSignalTitle = "Second"
        static let correlatedSignalTitle = "Correlated"
        static let firstColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let secondColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
        static let correlatedColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
    }
    
    // MARK: - Observables
    var lineChartData: Observable<LineChartData>
    var firstSignal: Observable<[Float]>
    var secondSignal: Observable<[Float]>
    var correlatedSignal: Observable<[Float]>
    var directTime: Observable<String>
    var fastTime: Observable<String>
    
    // MARK: - Subjects
    private let firstSignalBR = BehaviorRelay<[Float]>(value: [])
    private let secondSignalBR = BehaviorRelay<[Float]>(value: [])
    private let correlatedSignalBR = BehaviorRelay<[Float]>(value: [])
    private let lineChartDataRS = ReplaySubject<LineChartData>.create(bufferSize: 1)
    private let directTimeRS = ReplaySubject<String>.create(bufferSize: 1)
    private let fastTimeRS = ReplaySubject<String>.create(bufferSize: 1)
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        self.lineChartData = self.lineChartDataRS
        self.correlatedSignal = self.correlatedSignalBR.asObservable()
        self.firstSignal = self.firstSignalBR.asObservable()
        self.secondSignal = self.secondSignalBR.asObservable()
        self.directTime = self.directTimeRS
        self.fastTime = self.fastTimeRS
        
        self.setupBindings()
    }
    
    // MARK: - Methods
    func getCorrelatedSignal(_ firstSignal: Signal, _ secondSignal: Signal?, isAutocorrelation: Bool) {
        isAutocorrelation ? self.autocorrelation(for: firstSignal)
                          : self.correlation(for: firstSignal, and: secondSignal)
    }
    
    private func autocorrelation(for signal: Signal) {
        let values = self.formValues(for: signal)
        let correlated = Сorrelator.autocorrelation(for: values)
        self.correlatedSignalBR.accept(correlated)
    }
    
    private func correlation(for fSignal: Signal, and sSignal: Signal?) {
        guard let sSignal = sSignal else { return }
        let fValues = self.formValues(for: fSignal)
        let sValues = self.formValues(for: sSignal)
        let startTime = DispatchTime.now()
        let correlated = Сorrelator.correlation(for: fValues, and: sValues)
        let endTime = DispatchTime.now()
        let time = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000000
        self.directTimeRS.onNext(String(format: "%.4f ms", time))
        self.correlatedSignalBR.accept(correlated)
    }
    
    private func setupBindings() {
        let firstSignalValues = self.firstSignal
            .map({ self.createDataSet(color: Consts.firstColor, label: Consts.firstSignalTitle, values: $0) })
        
        let secondSignalValues = self.secondSignal
            .map({ self.createDataSet(color: Consts.secondColor, label: Consts.secondSignalTitle, values: $0) })
        
        let correlatedValues = self.correlatedSignal
            .map({ self.createDataSet(color: Consts.correlatedColor, label: Consts.correlatedSignalTitle, values: $0) })
        
        _ = Observable.combineLatest(firstSignalValues,
                                     secondSignalValues,
                                     correlatedValues,
                                     resultSelector: { (first, second, correlated) -> LineChartData  in
            return LineChartData(dataSets: [first, second, correlated])
        })
            .bind(to: self.lineChartDataRS)
            .disposed(by: self.disposeBag)
    }
    
    private func formValues(for signal: Signal) -> [Float] {
        var result = [Float]()
        for _ in 0..<Constants.frameCount {
            result.append(signal.getValue())
            signal.incrementPhase()
        }
        return result
    }
    
    private func createDataSet(color: CGColor, label: String, values: [Float]) -> LineChartDataSet {
        let dataSet = self.getDataSet(color: color, label: label)
        for (i, value) in values.enumerated() {
            dataSet.append(ChartDataEntry(x: Double(i), y: Double(value)))
        }
        return dataSet
    }
    
    
    private func getDataSet(color: CGColor, label: String, alpha: Double = 1.0) -> LineChartDataSet {
        let set = LineChartDataSet(label: label)
        set.mode = .linear
        set.drawCirclesEnabled = false
        set.drawFilledEnabled = true
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.fill = Fill(color: .clear)
        set.fillAlpha = CGFloat(alpha)
        set.highlightColor = .clear
        set.lineWidth = 2
        set.setColor(NSUIColor(cgColor: color) ?? .blue)
        return set
    }
}

// MARK: - Extension ViewModel
extension ViewModel: ViewModelType {
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
}
