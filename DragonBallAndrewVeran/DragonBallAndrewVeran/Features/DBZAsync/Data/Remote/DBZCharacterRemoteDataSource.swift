// LEARNING-CODE-GUIDE:
// Este archivo forma parte de una app de estudio progresiva iOS (tema Dragon Ball).
//
// Como leer este archivo (guia rapida):
// 1) Objetivo del archivo: identifica si es View, ViewModel, UseCase, Repository o Store.
// 2) Entrada principal: que dato recibe desde UI o capa superior.
// 3) Transformacion: que logica aplica a ese dato.
// 4) Salida: que devuelve/publica hacia la siguiente capa.
// 5) Logs: busca prints para seguir el viaje completo del dato en consola.
//
// Consejo de estudio:
// - Si te pierdes, sigue el flujo en este orden:
//   UI -> ViewModel/Presenter -> UseCase/Interactor -> Repository/Store -> Remote/DB -> UI.
// - Repite el flujo con un solo caso (ej: "Goku") hasta poder explicarlo sin mirar el codigo.
//
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
