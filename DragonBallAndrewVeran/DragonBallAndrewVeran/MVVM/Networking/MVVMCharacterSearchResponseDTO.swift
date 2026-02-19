//
//  MVVMCharacterSearchResponseDTO.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

/// La API a veces devuelve:
/// - un objeto personaje directo
/// - o un wrapper con items/meta/links
/// - o un array
/// Este “wrapper” intenta soportar los 3 casos y quedarse con el primer match.
struct MVVMCharacterSearchResponseDTO: Decodable {
    let character: MVVMCharacterDTO

    private enum Keys: String, CodingKey { case items }

    init(from decoder: Decoder) throws {
        // Caso 1: { "items": [ ... ] }
        if let keyed = try? decoder.container(keyedBy: Keys.self),
           let items = try? keyed.decode([MVVMCharacterDTO].self, forKey: .items),
           let first = items.first {
            character = first
            return
        }

        // Caso 2: [ ... ]
        if let single = try? decoder.singleValueContainer(),
           let array = try? single.decode([MVVMCharacterDTO].self),
           let first = array.first {
            character = first
            return
        }

        // Caso 3: { ... personaje ... }
        character = try MVVMCharacterDTO(from: decoder)
    }
}
