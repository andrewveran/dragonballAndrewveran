import Foundation
import Combine

/// Contrato del repositorio en dominio.
///
/// Senior interview note:
/// - El dominio solo conoce interfaces, no implementaciones concretas (DIP).
protocol DBZCheckRepository {
    func checkAnswer(_ answer: String) -> AnyPublisher<DBZCheckResult, Error>
}
