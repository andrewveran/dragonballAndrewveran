import Foundation

/// Respuesta tolerante para endpoint de busqueda por nombre.
/// Soporta variantes: { items: [...] }, [ ... ], o objeto directo.
struct DBZCharacterSearchResponseDTO: Decodable {
    let character: DBZCharacterDTO

    private enum Keys: String, CodingKey { case items }

    init(from decoder: Decoder) throws {
        if let keyed = try? decoder.container(keyedBy: Keys.self),
           let items = try? keyed.decode([DBZCharacterDTO].self, forKey: .items),
           let first = items.first {
            character = first
            return
        }

        if let single = try? decoder.singleValueContainer(),
           let array = try? single.decode([DBZCharacterDTO].self),
           let first = array.first {
            character = first
            return
        }

        character = try DBZCharacterDTO(from: decoder)
    }
}
