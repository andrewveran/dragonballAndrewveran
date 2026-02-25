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

/// Contrato del repositorio en dominio.
///
/// Senior interview note:
/// - El dominio solo conoce interfaces, no implementaciones concretas (DIP).
protocol DBZCheckRepository {
    /// FUNC-GUIDE: checkAnswer
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: checkAnswer
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResult, Error>
}
