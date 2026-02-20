import Foundation

/// Mapper Data -> Domain.
enum DBZCharacterMapper {
    static func map(_ dto: DBZCharacterDTO) -> DBZCharacter {
        DBZCharacter(
            id: dto.id ?? -1,
            name: dto.name ?? "Unknown",
            race: dto.race ?? "?",
            ki: dto.ki ?? "?",
            imageURL: URL(string: dto.image ?? "")
        )
    }
}
