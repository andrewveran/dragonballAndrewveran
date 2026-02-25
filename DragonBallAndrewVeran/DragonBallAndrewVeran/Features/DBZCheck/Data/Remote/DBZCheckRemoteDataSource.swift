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
import Combine

/// Contrato de fuente remota.
protocol DBZCheckRemoteDataSource {
    /// FUNC-GUIDE: checkAnswer
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: checkAnswer
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResponseDTO, Error>
}

final class DBZCheckRemoteDataSourceImpl: DBZCheckRemoteDataSource {
    private let client: NetworkClient

    /// Endpoint de Mockoon local (segun configuracion acordada).
    private let endpoint = URL(string: "http://localhost:3002/dbz/check")!

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(client: NetworkClient) {
        self.client = client
    }

    /// FUNC-GUIDE: checkAnswer
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: checkAnswer
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResponseDTO, Error> {
        print("[DATA][REMOTE] POST /dbz/check answer=\(answer)")

        let body = DBZCheckRequestDTO(answer: answer)
        return client.post(endpoint, body: body, as: DBZCheckResponseDTO.self)
    }
}
