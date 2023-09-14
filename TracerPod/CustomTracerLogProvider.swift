//
//  CustomTracerLogProvider.swift
//  Tracer
//
//

import Foundation

import OKTracer

final class CustomTracerLogProvider {
}

extension CustomTracerLogProvider: TracerLogProviderProtocol {

    func getData() -> Data? {
        "тестовые данные с текущим временем 1 \(Date())".data(using: .utf8)
    }
}
