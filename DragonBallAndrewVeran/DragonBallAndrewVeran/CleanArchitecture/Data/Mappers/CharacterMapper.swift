//
//  Untitled.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

enum CharacterMapper {
    static func map(_ dto: CACharacterDTO) -> Character {
        // [CA-7] Mapper transforma DTO (Data) → Entity (Domain)
        let id = dto.id ?? -1
        let name = dto.name ?? "Unknown"
        let race = dto.race ?? "?"
        let ki = dto.ki ?? "?"
        let imageURL = URL(string: dto.image ?? "")
        return Character(id: id, name: name, race: race, ki: ki, imageURL: imageURL)
    }
}
