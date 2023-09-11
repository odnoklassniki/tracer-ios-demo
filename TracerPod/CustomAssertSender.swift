//
//  CustomAssertSender.swift
//  TracerPod
//
//

import Foundation
import OKTracer

final class CustomAssertSender {
    
    // MARK: - Private properties
    
    private let tracerService: TracerServiceProtocol

    // MARK: - Initializations
    
    init(tracerService: TracerServiceProtocol) {
        self.tracerService = tracerService
    }
    
    // MARK: - Functions
    
    func send(message: String) {
        let model = TracerNonFatalModel(message: message, traceType: .current(dropFirstSymbols: 1))
        tracerService.send(nonFatal: model)
    }
}
