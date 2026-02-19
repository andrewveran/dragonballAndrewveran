//
//  CharacterRepositoryImpl.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

final class CharacterRepositoryImpl: CharacterRepository {
    private let remote: CharacterRemoteDataSource

    init(remote: CharacterRemoteDataSource) {
        self.remote = remote
    }

    func fetchCharacterByName(_ name: String) -> AnyPublisher<Character, Error> {
        // [CA-5] Repository decide de dónde vienen los datos (remote/local/cache)
        remote.fetchCharacterByName(name)
            .map { CharacterMapper.map($0) }
            .eraseToAnyPublisher()
    }
}
