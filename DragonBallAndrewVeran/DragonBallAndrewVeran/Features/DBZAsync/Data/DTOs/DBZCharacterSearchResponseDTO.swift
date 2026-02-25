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

/// Respuesta tolerante para endpoint de busqueda por nombre.
/// Soporta variantes: { items: [...] }, [ ... ], o objeto directo.
struct DBZCharacterSearchResponseDTO: Decodable {
    let character: DBZCharacterDTO

    private enum Keys: String, CodingKey { case items }

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(from decoder: Decoder) throws {
        if let keyed = try? decoder.container(keyedBy: Keys.self),
           let items = try? keyed.decode([DBZCharacterDTO].self, forKey: .items),
           let first = items.first {
            character = first
            return
        }

        if let single = try? decoder.singleValueContainer(),
           let array = try? single.decode([DBZCharacterDTO].self),
           let first = array.first {
            character = first
            return
        }

        character = try DBZCharacterDTO(from: decoder)
    }
}
