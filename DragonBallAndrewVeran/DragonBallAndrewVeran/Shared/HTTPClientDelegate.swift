//
//  HTTPClientDelegate.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

/// (Delegate pattern) Lo usamos solo para “ver” el viaje de la request sin meter prints por todo lado.
protocol HTTPClientDelegate: AnyObject {
    func httpClientDidStart(_ request: URLRequest)
    func httpClientDidFinish(_ request: URLRequest, statusCode: Int?)
    func httpClientDidFail(_ request: URLRequest, error: Error)
}

final class PrintHTTPClientDelegate: HTTPClientDelegate {
    func httpClientDidStart(_ request: URLRequest) {
        print("🛰️ [HTTP-DELEGATE] START -> \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
    }

    func httpClientDidFinish(_ request: URLRequest, statusCode: Int?) {
        print("✅ [HTTP-DELEGATE] FINISH -> status=\(statusCode.map(String.init) ?? "nil")")
    }

    func httpClientDidFail(_ request: URLRequest, error: Error) {
        print("❌ [HTTP-DELEGATE] FAIL -> \(error)")
    }
}
