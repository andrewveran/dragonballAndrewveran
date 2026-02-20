import Foundation

/// Caso de uso del dominio para buscar personaje por nombre.
protocol GetDBZCharacterByNameUseCase {
    func execute(name: String) async throws -> DBZCharacter
}

final class GetDBZCharacterByNameUseCaseImpl: GetDBZCharacterByNameUseCase {
    private let repository: DBZCharacterRepository

    init(repository: DBZCharacterRepository) {
        self.repository = repository
    }

    func execute(name: String) async throws -> DBZCharacter {
        print("[DOMAIN][USE_CASE][ASYNC] execute(name=\(name))")
        return try await repository.getCharacterByName(name)
    }
}
