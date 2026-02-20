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

/// Estado de UI.
///
/// Equatable se usa para permitir .onChange(of:) en SwiftUI.
enum DBZCheckViewState: Equatable {
    case idle
    case loading
    case success(message: String)
    case failure(message: String)
}

/// ViewModel (MVVM): transforma eventos de UI en acciones de dominio.
final class DBZCheckViewModel: ObservableObject {
    /// Texto que escribe el usuario en pantalla.
    @Published var inputText: String = ""

    /// Estado expuesto solo lectura hacia la vista.
    @Published private(set) var state: DBZCheckViewState = .idle

    private let useCase: CheckDBZAnswerUseCase

    /// Bolsa de subscripciones Combine.
    ///
    /// Senior interview note:
    /// - Sin guardar AnyCancellable, el stream se libera y no entrega valores.
    private var cancellables = Set<AnyCancellable>()

    init(useCase: CheckDBZAnswerUseCase) {
        self.useCase = useCase
    }

    func submit() {
        // Normalizamos input (evita errores por espacios accidentales).
        let answer = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[PRESENTATION][VIEW_MODEL] submit(answer=\(answer))")

        guard !answer.isEmpty else {
            state = .failure(message: "Escribe un valor. Ejemplo: Goku")
            return
        }

        state = .loading

        // Cancelamos requests anteriores antes de enviar una nueva.
        // Senior note: evita estados viejos llegando tarde (race en UI).
        cancellables.removeAll()

        useCase.execute(answer: answer)
            // UI state siempre en main thread.
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("[PRESENTATION][VIEW_MODEL] completion=finished")
                case .failure(let error):
                    print("[PRESENTATION][VIEW_MODEL] completion=failure error=\(error.localizedDescription)")
                    self?.state = .failure(message: "Error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] result in
                print("[PRESENTATION][VIEW_MODEL] receiveValue(isCorrect=\(result.isCorrect), message=\(result.message))")
                self?.state = result.isCorrect ? .success(message: result.message) : .failure(message: result.message)
            }
            .store(in: &cancellables)
    }
}
