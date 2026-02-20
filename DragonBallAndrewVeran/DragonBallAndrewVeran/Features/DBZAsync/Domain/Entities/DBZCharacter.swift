import Foundation

/// Entidad de dominio para la Pantalla 2 (API real de DBZ).
///
/// Senior interview note:
/// - Domain Entity debe ser estable y no depender del formato del backend.
struct DBZCharacter: Equatable {
    let id: Int
    let name: String
    let race: String
    let ki: String
    let imageURL: URL?
}
