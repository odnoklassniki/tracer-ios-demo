//
//  CustomTracerSystemInfo.swift
//  Tracer
//
//

import Foundation
import OKTracer

struct CustomTracerSystemInfo: TracerSystemInfoProtocol {
    
    // MARK: - TracerSystemInfoProtocol propertires
    
    let model: String
    let orientation: String
    let freeRAM: Double
    let diskFree: Int64
    let osType: String
    let osVersion: String
    let appVersion: String
    let appVersionCode: Int
    let deviceId: String
    let inBackground: Bool
    let properties: [String: String]
    let vendor: String
    let tags: [String]
    let isRooted: Bool?
    let processName: String?
}
