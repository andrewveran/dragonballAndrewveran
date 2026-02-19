//
//  CharacterRepository.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

protocol CharacterRepository {
    func fetchCharacterByName(_ name: String) -> AnyPublisher<Character, Error>
}
