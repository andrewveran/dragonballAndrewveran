//
//  HTTPClient.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

protocol HTTPClient {
    func get<T: Decodable>(_ url: URL, as type: T.Type) -> AnyPublisher<T, Error>
}

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    weak var delegate: HTTPClientDelegate?

    init(session: URLSession = .shared, delegate: HTTPClientDelegate? = nil) {
        self.session = session
        self.delegate = delegate
    }

    func get<T: Decodable>(_ url: URL, as type: T.Type) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // [HTTP-1] Empieza viaje: construimos request
        delegate?.httpClientDidStart(request)

        // [HTTP-2] URLSession hace la petición
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                let http = response as? HTTPURLResponse
                self?.delegate?.httpClientDidFinish(request, statusCode: http?.statusCode)

                guard let http, (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            // [HTTP-3] Decodificamos JSON → DTO
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
