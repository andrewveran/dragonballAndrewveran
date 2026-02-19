//
//  DragonBallRemoteDataSource.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

final class DragonBallRemoteDataSource: CharacterRemoteDataSource {
    private let http: HTTPClient
    private let baseURL = URL(string: "https://dragonball-api.com/api")!

    init(http: HTTPClient) {
        self.http = http
    }

    func fetchCharacterByName(_ name: String) -> AnyPublisher<CACharacterDTO, Error> {
        // [CA-6] DataSource arma endpoint y llama al HTTPClient
        var comps = URLComponents(url: baseURL.appendingPathComponent("characters"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "name", value: name.lowercased())]
        let url = comps.url!

        return http.get(url, as: CACharacterSearchResponseDTO.self)
            .map { $0.character }
            .eraseToAnyPublisher()
    }
}
