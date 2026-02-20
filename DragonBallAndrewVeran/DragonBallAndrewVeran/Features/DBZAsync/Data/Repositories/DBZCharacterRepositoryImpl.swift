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
