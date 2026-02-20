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
