import Foundation
import Combine

/// Implementacion concreta del contrato de dominio.
final class DBZCheckRepositoryImpl: DBZCheckRepository {
    private let remote: DBZCheckRemoteDataSource

    init(remote: DBZCheckRemoteDataSource) {
        self.remote = remote
    }

    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResult, Error> {
        print("[DATA][REPOSITORY] checkAnswer(answer=\(answer))")

        // Origen de datos actual: remoto.
        // Aqui luego puedes combinar cache/local/remote.
        return remote.checkAnswer(answer)
            .map(DBZCheckMapper.map)
            .eraseToAnyPublisher()
    }
}
