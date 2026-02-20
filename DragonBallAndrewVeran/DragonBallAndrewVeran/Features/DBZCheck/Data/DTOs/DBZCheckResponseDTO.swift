import Foundation

/// DTO de respuesta de API.
/// Soporta dos variantes comunes: isCorrect o is_correct.
struct DBZCheckResponseDTO: Decodable {
    let isCorrect: Bool
    let message: String

    private enum CodingKeys: String, CodingKey {
        case isCorrect
        case is_correct
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Tolerancia de formato para reducir fragilidad ante cambios leves de backend.
        if let value = try? container.decode(Bool.self, forKey: .isCorrect) {
            isCorrect = value
        } else {
            isCorrect = (try? container.decode(Bool.self, forKey: .is_correct)) ?? false
        }

        message = (try? container.decode(String.self, forKey: .message)) ?? "Sin mensaje"
    }
}
