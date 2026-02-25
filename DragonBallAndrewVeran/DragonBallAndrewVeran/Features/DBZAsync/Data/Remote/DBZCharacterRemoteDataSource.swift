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
    /// FUNC-GUIDE: fetchCharacterByName
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: fetchCharacterByName
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func fetchCharacterByName(_ name: String) async throws -> DBZCharacterDTO
}

final class DBZCharacterRemoteDataSourceImpl: DBZCharacterRemoteDataSource {
    private let session: URLSession
    private let baseURL = URL(string: "https://dragonball-api.com/api")!

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// FUNC-GUIDE: fetchCharacterByName
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: fetchCharacterByName
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
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
