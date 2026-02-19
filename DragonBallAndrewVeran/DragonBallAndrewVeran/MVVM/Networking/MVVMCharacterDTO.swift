//
//  MVVMCharacterDTO.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

/// Decodable “tolerante”: campos opcionales para que no explote si falta algo.
struct MVVMCharacterDTO: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let race: String?
    let ki: String?
    let description: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case id, name, race, ki, description
        case image
        case image_url // por si alguna vez viene así
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try? c.decode(Int.self, forKey: .id)
        name = try? c.decode(String.self, forKey: .name)
        race = try? c.decode(String.self, forKey: .race)
        ki = try? c.decode(String.self, forKey: .ki)
        description = try? c.decode(String.self, forKey: .description)

        // intenta image primero, si no, image_url
        if let img = try? c.decode(String.self, forKey: .image) {
            image = img
        } else {
            image = try? c.decode(String.self, forKey: .image_url)
        }
    }
}
