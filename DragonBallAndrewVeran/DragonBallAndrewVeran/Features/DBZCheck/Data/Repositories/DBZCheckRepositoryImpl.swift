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
