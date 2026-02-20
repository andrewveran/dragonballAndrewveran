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

/// Caso de uso del dominio para buscar personaje por nombre.
protocol GetDBZCharacterByNameUseCase {
    func execute(name: String) async throws -> DBZCharacter
}

final class GetDBZCharacterByNameUseCaseImpl: GetDBZCharacterByNameUseCase {
    private let repository: DBZCharacterRepository

    init(repository: DBZCharacterRepository) {
        self.repository = repository
    }

    func execute(name: String) async throws -> DBZCharacter {
        print("[DOMAIN][USE_CASE][ASYNC] execute(name=\(name))")
        return try await repository.getCharacterByName(name)
    }
}
