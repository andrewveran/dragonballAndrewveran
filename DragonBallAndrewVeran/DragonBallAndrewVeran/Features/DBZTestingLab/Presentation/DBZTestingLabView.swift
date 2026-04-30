import Combine
import SwiftUI

private struct DBZTestResult: Identifiable {
    let id = UUID()
    let name: String
    let passed: Bool
    let detail: String
}

private protocol DBZPowerService {
    func fetchPower(for fighter: String) async throws -> Int
}

private struct DBZDeterministicPowerService: DBZPowerService {
    func fetchPower(for fighter: String) async throws -> Int {
        switch fighter.lowercased() {
        case "goku":
            return 9001
        case "krillin":
            return 1800
        default:
            return 500
        }
    }
}

private struct DBZFailingPowerService: DBZPowerService {
    func fetchPower(for fighter: String) async throws -> Int {
        throw NSError(domain: "DBZTestingLab", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fallo simulado para \(fighter)"])
    }
}

private struct DBZPowerRankingUseCase {
    let service: any DBZPowerService

    func execute(fighter: String) async throws -> String {
        let power = try await service.fetchPower(for: fighter)
        if power >= 9000 { return "S" }
        if power >= 2000 { return "A" }
        return "B"
    }
}

@MainActor
private final class DBZTestingLabViewModel: ObservableObject {
    @Published private(set) var results: [DBZTestResult] = []

    func runSuite() {
        results = []

        Task {
            await runDeterministicSuccessTest()
            await runBoundaryTest()
            await runFailureTest()
        }
    }

    private func appendResult(_ result: DBZTestResult) {
        results.append(result)
    }

    private func runDeterministicSuccessTest() async {
        let useCase = DBZPowerRankingUseCase(service: DBZDeterministicPowerService())
        do {
            let rank = try await useCase.execute(fighter: "goku")
            appendResult(DBZTestResult(name: "testGokuRankIsS", passed: rank == "S", detail: "rank=\(rank)"))
        } catch {
            appendResult(DBZTestResult(name: "testGokuRankIsS", passed: false, detail: error.localizedDescription))
        }
    }

    private func runBoundaryTest() async {
        let useCase = DBZPowerRankingUseCase(service: DBZDeterministicPowerService())
        do {
            let rank = try await useCase.execute(fighter: "krillin")
            appendResult(DBZTestResult(name: "testKrillinFallsIntoB", passed: rank == "B", detail: "rank=\(rank)"))
        } catch {
            appendResult(DBZTestResult(name: "testKrillinFallsIntoB", passed: false, detail: error.localizedDescription))
        }
    }

    private func runFailureTest() async {
        let useCase = DBZPowerRankingUseCase(service: DBZFailingPowerService())
        do {
            _ = try await useCase.execute(fighter: "vegeta")
            appendResult(DBZTestResult(name: "testFailurePath", passed: false, detail: "Se esperaba error"))
        } catch {
            appendResult(DBZTestResult(name: "testFailurePath", passed: true, detail: error.localizedDescription))
        }
    }
}

struct DBZTestingLabView: View {
    @StateObject private var viewModel = DBZTestingLabViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 25: Testing Lab Real")
                    .font(.title3.bold())

                Text("Practica unit tests mentales dentro de la app: caso feliz, boundary y manejo de error con doubles deterministas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Ejecutar suite de pruebas") {
                    viewModel.runSuite()
                }
                .buttonStyle(.borderedProminent)

                ForEach(viewModel.results) { result in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(result.name)
                            .font(.headline)
                        Text(result.passed ? "PASS" : "FAIL")
                            .font(.caption.bold())
                            .foregroundStyle(result.passed ? .green : .red)
                        Text(result.detail)
                            .font(.footnote.monospaced())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("DBZ Testing")
    }
}
