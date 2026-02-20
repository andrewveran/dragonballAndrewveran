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
