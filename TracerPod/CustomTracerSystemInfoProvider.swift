//
//  CustomTracerSystemInfoProvider.swift
//  Tracer
//
//

import Foundation
import OKTracer

final class CustomTracerSystemInfoProvider {
    
    // MARK: - Private properties
    
    private var properties: [String: String] = [:]
    private var tags: [String: String] = [:]
}

extension CustomTracerSystemInfoProvider: TracerSystemInfoProviderProtocol {
    
    // MARK: - TracerSystemInfoProviderProtocol functions
    
    func info() -> TracerSystemInfoProtocol {
        CustomTracerSystemInfo(model: "custom model",
                               orientation: "custom orientation",
                               freeRAM: 100,
                               diskFree: 200,
                               osType: "custom osType",
                               osVersion: "custom osVersion",
                               appVersion: "custom appVersion",
                               appVersionCode: 300,
                               deviceId: "custom deviceId",
                               inBackground: false,
                               properties: properties,
                               vendor: "custom vendor",
                               tags: tags.compactMap({ "\($0.key)=\($0.value)" }),
                               isRooted: false,
                               processName: "custom processName")
    }
    
    func set(properties: [String: String]) {
        self.properties = properties
    }
    
    func set(tags: [String: String]) {
        self.tags = tags
    }
}
