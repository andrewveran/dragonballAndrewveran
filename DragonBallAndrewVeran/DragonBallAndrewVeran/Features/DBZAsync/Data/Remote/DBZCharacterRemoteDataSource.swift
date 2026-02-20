import Foundation

/// Contrato de fuente remota (async/await).
protocol DBZCharacterRemoteDataSource {
    func fetchCharacterByName(_ name: String) async throws -> DBZCharacterDTO
}

final class DBZCharacterRemoteDataSourceImpl: DBZCharacterRemoteDataSource {
    private let session: URLSession
    private let baseURL = URL(string: "https://dragonball-api.com/api")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCharacterByName(_ name: String) async throws -> DBZCharacterDTO {
        var comps = URLComponents(url: baseURL.appendingPathComponent("characters"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "name", value: name.lowercased())]
        let url = comps.url!

        print("[DATA][REMOTE][ASYNC] GET \(url.absoluteString)")

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let raw = String(data: data, encoding: .utf8) {
            print("[NETWORK][RESPONSE_BODY][ASYNC] \(raw)")
        }

        let decoded = try JSONDecoder().decode(DBZCharacterSearchResponseDTO.self, from: data)
        return decoded.character
    }
}
