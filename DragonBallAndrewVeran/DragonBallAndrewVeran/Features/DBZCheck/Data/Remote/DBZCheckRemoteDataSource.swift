import Foundation
import Combine

/// Contrato de fuente remota.
protocol DBZCheckRemoteDataSource {
    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResponseDTO, Error>
}

final class DBZCheckRemoteDataSourceImpl: DBZCheckRemoteDataSource {
    private let client: NetworkClient

    /// Endpoint de Mockoon local (segun configuracion acordada).
    private let endpoint = URL(string: "http://localhost:3002/dbz/check")!

    init(client: NetworkClient) {
        self.client = client
    }

    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResponseDTO, Error> {
        print("[DATA][REMOTE] POST /dbz/check answer=\(answer)")

        let body = DBZCheckRequestDTO(answer: answer)
        return client.post(endpoint, body: body, as: DBZCheckResponseDTO.self)
    }
}
