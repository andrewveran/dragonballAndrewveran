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

struct DBZAsyncCharacterViewData: Equatable {
    let name: String
    let race: String
    let ki: String
    let imageURL: URL?
}

enum DBZAsyncViewState: Equatable {
    case idle
    case loading
    case loaded(DBZAsyncCharacterViewData)
    case error(message: String)
}

/// MainActor garantiza que cambios de estado de UI ocurren en el hilo principal.
@MainActor
final class DBZAsyncViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published private(set) var state: DBZAsyncViewState = .idle

    private let useCase: GetDBZCharacterByNameUseCase

    init(useCase: GetDBZCharacterByNameUseCase) {
        self.useCase = useCase
    }

    /// Metodo async para ser ejecutado dentro de un Task desde la vista.
    func submit() async {
        let query = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[PRESENTATION][VIEW_MODEL][ASYNC] submit(query=\(query))")

        guard !query.isEmpty else {
            state = .error(message: "Escribe un nombre. Ejemplo: Goku")
            return
        }

        state = .loading

        do {
            let character = try await useCase.execute(name: query)
            let viewData = DBZAsyncCharacterViewData(
                name: character.name,
                race: character.race,
                ki: character.ki,
                imageURL: character.imageURL
            )
            state = .loaded(viewData)
            print("[PRESENTATION][VIEW_MODEL][ASYNC] success(name=\(character.name))")
        } catch {
            state = .error(message: "Error: \(error.localizedDescription)")
            print("[PRESENTATION][VIEW_MODEL][ASYNC] failure(error=\(error.localizedDescription))")
        }
    }
}
