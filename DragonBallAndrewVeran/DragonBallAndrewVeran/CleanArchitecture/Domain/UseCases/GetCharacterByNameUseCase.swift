//
//  GetCharacterByNameUseCase.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

protocol GetCharacterByNameUseCase {
    func execute(name: String) -> AnyPublisher<Character, Error>
}

final class GetCharacterByNameUseCaseImpl: GetCharacterByNameUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(name: String) -> AnyPublisher<Character, Error> {
        // [CA-3] UseCase orquesta el caso de uso (reglas del dominio si existieran)
        repository.fetchCharacterByName(name)
    }
}
