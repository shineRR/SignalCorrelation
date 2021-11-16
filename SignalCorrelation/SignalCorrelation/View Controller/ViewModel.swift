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
    var firstSignal: Observable<LineChartData> { get }
    var secondSignal: Observable<LineChartData> { get }
    var directLineChartData: Observable<LineChartData> { get }
    var fastLineChartData: Observable<LineChartData> { get }
    var directTime: Observable<String> { get }
    var fastTime: Observable<String> { get }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    typealias CorrelationWork = ([Float], String)
    
    // MARK: - Consts
    enum Consts {
        static let zeroData = LineChartData(dataSets: [])
        static let firstSignalTitle = "First"
        static let secondSignalTitle = "Second"
        static let correlatedSignalTitle = "Correlated"
        static let firstColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let secondColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
        static let correlatedColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        static let fastCorrelatedColor = CGColor(red: 0, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: - Observables
    private var fSignal: Observable<[Float]>
    private var sSignal: Observable<[Float]>
    private var directSignal: Observable<[Float]>
    private var fastSignal: Observable<[Float]>
    var directLineChartData: Observable<LineChartData>
    var fastLineChartData: Observable<LineChartData>
    var firstSignal: Observable<LineChartData>
    var secondSignal: Observable<LineChartData>
    var directTime: Observable<String>
    var fastTime: Observable<String>
    
    // MARK: - Subjects
    private let firstSignalRS = ReplaySubject<LineChartData>.create(bufferSize: 1)
    private let secondSignalRS = ReplaySubject<LineChartData>.create(bufferSize: 1)
    private let directLineChartDataRS = ReplaySubject<LineChartData>.create(bufferSize: 1)
    private let fastLineChartDataRS = ReplaySubject<LineChartData>.create(bufferSize: 1)
    private let directTimeRS = ReplaySubject<String>.create(bufferSize: 1)
    private let fastTimeRS = ReplaySubject<String>.create(bufferSize: 1)
    
    private let fSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    private let sSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    private let directSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    private let fastSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        self.fastLineChartData = self.fastLineChartDataRS
        self.directLineChartData = self.directLineChartDataRS
        self.directTime = self.directTimeRS
        self.fastTime = self.fastTimeRS
        self.firstSignal = self.firstSignalRS
        self.secondSignal = self.secondSignalRS
        self.fSignal = self.fSignalRS
        self.sSignal = self.sSignalRS
        self.directSignal = self.directSignalRS
        self.fastSignal = self.fastSignalRS
        
        self.setupBindings()
    }
    
    // MARK: - Methods
    func getCorrelatedSignal(_ firstSignal: Signal, _ secondSignal: Signal?, isAutocorrelation: Bool) {
        isAutocorrelation ? self.autocorrelation(for: firstSignal)
                          : self.correlation(for: firstSignal, and: secondSignal)
    }
    
    private func autocorrelation(for signal: Signal) {
        let values = self.formValues(for: signal)
        
        self.sendValues(fSignal: values)
        self.prepareWork(for: values, and: values)
    }
    
    private func correlation(for fSignal: Signal, and sSignal: Signal?) {
        guard let sSignal = sSignal else { return }
        let fValues = self.formValues(for: fSignal)
        let sValues = self.formValues(for: sSignal)
        
        self.sendValues(fSignal: fValues, sSignal: sValues)
        self.prepareWork(for: fValues, and: sValues)
    }
    
    private func sendValues(fSignal: [Float] = [], sSignal: [Float] = [],
                            dSignal: [Float] = [], fastSignal: [Float] = []) {
        self.fSignalRS.onNext(fSignal)
        self.sSignalRS.onNext(sSignal)
        self.directSignalRS.onNext(dSignal)
        self.fastSignalRS.onNext(fastSignal)
    }
    
    private func prepareWork(for fValues: [Float], and sValues: [Float]) {
        self.performWork({ Сorrelator.correlation(for: fValues, and: sValues) })
            .subscribe(onSuccess: { [weak self] values, time in
                self?.directSignalRS.onNext(values)
                self?.directTimeRS.onNext(time)
            })
            .disposed(by: self.disposeBag)
        
        
        self.performWork({ Сorrelator.fastCorrelation(for: fValues, and: sValues) })
            .subscribe(onSuccess: { [weak self] values, time in
                self?.fastSignalRS.onNext(values)
                self?.fastTimeRS.onNext(time)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func performWork(_ action: @escaping (() -> [Float])) -> Single<CorrelationWork> {
        return Single<CorrelationWork>.create { observer in
            let startTime = DispatchTime.now()
            let values = action()
            let endTime = DispatchTime.now()
            let time = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000000
            
            observer(.success((values, String(format: "%.4f ms", time))))
            return Disposables.create()
        }
    }
    
    private func setupBindings() {
        self.fSignal
            .map({ self.createDataSet(color: Consts.firstColor, label: Consts.firstSignalTitle, values: $0) })
            .map({ LineChartData(dataSet: $0)})
            .bind(to: self.firstSignalRS)
            .disposed(by: self.disposeBag)
        
        self.sSignal
            .map({ self.createDataSet(color: Consts.secondColor, label: Consts.secondSignalTitle, values: $0) })
            .map({ LineChartData(dataSet: $0)})
            .bind(to: self.secondSignalRS)
            .disposed(by: self.disposeBag)
        
        self.directSignal
            .map({ self.createDataSet(color: Consts.correlatedColor, label: Consts.correlatedSignalTitle, values: $0) })
            .map({ LineChartData(dataSet: $0)})
            .bind(to: self.directLineChartDataRS)
            .disposed(by: self.disposeBag)
        
        self.fastSignal
            .map({ self.createDataSet(color: Consts.fastCorrelatedColor, label: Consts.correlatedSignalTitle, values: $0) })
            .map({ LineChartData(dataSet: $0)})
            .bind(to: self.fastLineChartDataRS)
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
