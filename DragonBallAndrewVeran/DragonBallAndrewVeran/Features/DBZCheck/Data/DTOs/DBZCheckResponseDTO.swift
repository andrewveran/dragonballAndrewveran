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

/// DTO de respuesta de API.
/// Soporta dos variantes comunes: isCorrect o is_correct.
struct DBZCheckResponseDTO: Decodable {
    let isCorrect: Bool
    let message: String

    private enum CodingKeys: String, CodingKey {
        case isCorrect
        case is_correct
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Tolerancia de formato para reducir fragilidad ante cambios leves de backend.
        if let value = try? container.decode(Bool.self, forKey: .isCorrect) {
            isCorrect = value
        } else {
            isCorrect = (try? container.decode(Bool.self, forKey: .is_correct)) ?? false
        }

        message = (try? container.decode(String.self, forKey: .message)) ?? "Sin mensaje"
    }
}
