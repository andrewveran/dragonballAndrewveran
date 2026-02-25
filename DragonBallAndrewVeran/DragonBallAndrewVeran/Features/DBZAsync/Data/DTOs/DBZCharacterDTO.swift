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

/// DTO tolerante de personaje DBZ (API real).
struct DBZCharacterDTO: Decodable {
    let id: Int?
    let name: String?
    let race: String?
    let ki: String?
    let image: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, race, ki, image
        case image_url
    }

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decode(Int.self, forKey: .id)
        name = try? c.decode(String.self, forKey: .name)
        race = try? c.decode(String.self, forKey: .race)
        ki = try? c.decode(String.self, forKey: .ki)

        if let img = try? c.decode(String.self, forKey: .image) {
            image = img
        } else {
            image = try? c.decode(String.self, forKey: .image_url)
        }
    }
}
