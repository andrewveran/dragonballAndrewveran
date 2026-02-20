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

/// Caso de uso (regla de negocio de la pantalla).
protocol CheckDBZAnswerUseCase {
    func execute(answer: String) -> AnyPublisher<DBZCheckResult, Error>
}

final class CheckDBZAnswerUseCaseImpl: CheckDBZAnswerUseCase {
    private let repository: DBZCheckRepository

    init(repository: DBZCheckRepository) {
        self.repository = repository
    }

    func execute(answer: String) -> AnyPublisher<DBZCheckResult, Error> {
        print("[DOMAIN][USE_CASE] execute(answer=\(answer))")

        // Aqui vivira la validacion/regla si en futuro crece la logica.
        return repository.checkAnswer(answer)
    }
}
