//
//  CustomTracerLogProvider.swift
//  Tracer
//
//

import Foundation

import OKTracer

final class CustomTracerLogProvider {
}

extension CustomTracerLogProvider: TracerLoggerProtocol {
    
    // MARK: - TracerLogProviderProtocol
    
    func log() -> Data? {
        "тестовые данные с текущим временем 1 \(Date())".data(using: .utf8)
    }
}
