import Foundation

/// Mapper DTO -> Entity.
///
/// Senior interview note:
/// - El mapper evita "contaminar" Domain con detalles de API.
enum DBZCheckMapper {
    static func map(_ dto: DBZCheckResponseDTO) -> DBZCheckResult {
        DBZCheckResult(isCorrect: dto.isCorrect, message: dto.message)
    }
}
