import Foundation

/// Contrato del repositorio en dominio (async/await).
protocol DBZCharacterRepository {
    func getCharacterByName(_ name: String) async throws -> DBZCharacter
}
