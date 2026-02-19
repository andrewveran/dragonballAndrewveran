//
//  MVVMDragonBallService.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

protocol MVVMDragonBallServiceType {
    func fetchCharacterByName(_ name: String) -> AnyPublisher<MVVMCharacterDTO, Error>
}

final class MVVMDragonBallService: MVVMDragonBallServiceType {
    private let http: HTTPClient
    private let baseURL = URL(string: "https://dragonball-api.com/api")!

    init(http: HTTPClient) {
        self.http = http
    }

    func fetchCharacterByName(_ name: String) -> AnyPublisher<MVVMCharacterDTO, Error> {
        // [MVVM-SERVICE-1] Construimos endpoint (API)
        // Ejemplo documentado: /api/characters?name=goku :contentReference[oaicite:1]{index=1}
        var comps = URLComponents(url: baseURL.appendingPathComponent("characters"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "name", value: name.lowercased())]
        let url = comps.url!

        // [MVVM-SERVICE-2] HTTPClient hace request → decodifica response
        return http.get(url, as: MVVMCharacterSearchResponseDTO.self)
            // [MVVM-SERVICE-3] Extraemos el personaje (DTO)
            .map { $0.character }
            .eraseToAnyPublisher()
    }
}
