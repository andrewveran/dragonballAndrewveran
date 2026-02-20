import Foundation

/// Entidad de dominio: modelo estable para reglas de negocio.
///
/// Senior interview note:
/// - Domain no debe depender de DTOs ni detalles de API.
struct DBZCheckResult {
    let isCorrect: Bool
    let message: String
}
