//
//  Untitled.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

struct CACharacterSearchResponseDTO: Decodable {
    let character: CACharacterDTO

    private enum Keys: String, CodingKey { case items }

    init(from decoder: Decoder) throws {
        if let keyed = try? decoder.container(keyedBy: Keys.self),
           let items = try? keyed.decode([CACharacterDTO].self, forKey: .items),
           let first = items.first {
            character = first
            return
        }

        if let single = try? decoder.singleValueContainer(),
           let array = try? single.decode([CACharacterDTO].self),
           let first = array.first {
            character = first
            return
        }

        character = try CACharacterDTO(from: decoder)
    }
}
