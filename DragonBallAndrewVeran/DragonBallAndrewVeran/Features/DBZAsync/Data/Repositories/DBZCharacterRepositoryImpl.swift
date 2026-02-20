import Foundation

/// Implementacion del repositorio para Pantalla 2.
final class DBZCharacterRepositoryImpl: DBZCharacterRepository {
    private let remote: DBZCharacterRemoteDataSource

    init(remote: DBZCharacterRemoteDataSource) {
        self.remote = remote
    }

    func getCharacterByName(_ name: String) async throws -> DBZCharacter {
        print("[DATA][REPOSITORY][ASYNC] getCharacterByName(name=\(name))")
        let dto = try await remote.fetchCharacterByName(name)
        return DBZCharacterMapper.map(dto)
    }
}
