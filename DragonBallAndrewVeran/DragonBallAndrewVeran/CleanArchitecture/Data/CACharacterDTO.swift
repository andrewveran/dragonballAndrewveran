//
//  CACharacterDTO.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

struct CACharacterDTO: Decodable {
    let id: Int?
    let name: String?
    let race: String?
    let ki: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case id, name, race, ki, image
        case image_url
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(Int.self, forKey: .id)
        name = try? c.decode(String.self, forKey: .name)
        race = try? c.decode(String.self, forKey: .race)
        ki = try? c.decode(String.self, forKey: .ki)

        if let img = try? c.decode(String.self, forKey: .image) {
            image = img
        } else {
            image = try? c.decode(String.self, forKey: .image_url)
        }
    }
}
