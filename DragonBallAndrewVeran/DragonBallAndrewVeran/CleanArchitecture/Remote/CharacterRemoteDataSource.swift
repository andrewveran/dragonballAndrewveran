//
//  CharacterRemoteDataSource.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

protocol CharacterRemoteDataSource {
    func fetchCharacterByName(_ name: String) -> AnyPublisher<CACharacterDTO, Error>
}
