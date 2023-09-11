//
//  CustomTracerURLProxy.swift
//  Tracer
//
//

import Foundation
import OKTracer

final class CustomTracerURLProxy {
}

extension CustomTracerURLProxy: TracerURLProxyProtocol {
    
    // MARK: - TracerURLProxyProtocol functions
    
    func modifyRequest(_ request: URLRequest) -> URLRequest {
        request
    }

    func canHandle(forHost host: String) -> Bool {
        true
    }

    func handle(_ challenge: URLAuthenticationChallenge, completion: @escaping TracerURLProxyCompletion) -> Bool {
        var credential: URLCredential?
        if let serverTrust = challenge.protectionSpace.serverTrust {
            credential = URLCredential(trust: serverTrust)
        }
        completion(.useCredential, credential)
        return true
    }
}
