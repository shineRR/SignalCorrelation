//
// ViewModel.swift
// SignalCorrelation
//
// Created by Ilya Baryko on 14.11.21.
// 
//


import Foundation
import RxSwift

protocol ViewModelType {
    var inputs: ViewModelInputs { get }
    var outputs: ViewModelOutputs { get }
}

protocol ViewModelInputs {
    func getCorrelatedSignal(_ firstSignal: Signal?, _ secondSignal: Signal?)
}

protocol ViewModelOutputs {
    var firstSignal: Observable<[Float]> { get }
    var secondSignal: Observable<[Float]> { get }
    var correlatedSignal: Observable<[Float]> { get }
    var directTime: Observable<String> { get }
    var fastTime: Observable<String> { get }
}

class ViewModel: ViewModelInputs, ViewModelOutputs {
    
    // MARK: - Observables
    var firstSignal: Observable<[Float]>
    var secondSignal: Observable<[Float]>
    var correlatedSignal: Observable<[Float]>
    var directTime: Observable<String>
    var fastTime: Observable<String>
    
    // MARK: - Subjects
    private let firstSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    private let secondSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    private let correlatedSignalRS = ReplaySubject<[Float]>.create(bufferSize: 1)
    private let directTimeRS = ReplaySubject<String>.create(bufferSize: 1)
    private let fastTimeRS = ReplaySubject<String>.create(bufferSize: 1)
    
    // MARK: - Init
    init() {
        self.correlatedSignal = self.correlatedSignalRS
        self.firstSignal = self.firstSignalRS
        self.secondSignal = self.secondSignalRS
        self.directTime = self.directTimeRS
        self.fastTime = self.fastTimeRS
    }
    
    // MARK: - Methods
    func getCorrelatedSignal(_ firstSignal: Signal?, _ secondSignal: Signal?) {
//        let first = self.formValues(for: firstSignal)
//        let second = self.formValues(for: secondSignal)
//        let a = Сorrelator.correlation(for: [2, 5, 3], and: [5, 1, 2])
//        let a = Сorrelator.autocorrelation(for: [1, 1, -1])
//        print(a)
    }
    
    private func formValues(for signal: Signal) -> [Float] {
        var result = [Float]()
        for _ in 0..<Constants.frameCount {
            result.append(signal.getValue())
            signal.incrementPhase()
        }
        return result
    }
}

// MARK: - Extension ViewModel
extension ViewModel: ViewModelType {
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
}
