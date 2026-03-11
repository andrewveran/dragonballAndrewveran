import SwiftUI
import Combine

@MainActor
private final class DBZInstrumentsNetworkViewModel: ObservableObject {
    @Published private(set) var requests = 0
    @Published private(set) var bytes = 0
    @Published private(set) var status = "Idle"

    private let endpoint = URL(string: "https://dragonball-api.com/api/characters?limit=1")!

    func runNormal() {
        status = "1 request en curso..."
        Task {
            do {
                let data = try await fetchOnce()
                requests += 1
                bytes += data.count
                status = "Normal completado"
            } catch {
                status = "Error: \(error.localizedDescription)"
            }
        }
    }

    func runProblem() {
        status = "Burst de requests en curso..."
        let endpoint = self.endpoint
        Task {
            do {
                try await withThrowingTaskGroup(of: Int.self) { group in
                    for _ in 0..<20 {
                        group.addTask {
                            let (data, _) = try await URLSession.shared.data(from: endpoint)
                            return data.count
                        }
                    }

                    var total = 0
                    var count = 0
                    for try await size in group {
                        total += size
                        count += 1
                    }

                    await MainActor.run {
                        self.requests += count
                        self.bytes += total
                        self.status = "Burst completado"
                    }
                }
            } catch {
                status = "Error: \(error.localizedDescription)"
            }
        }
    }

    func reset() {
        requests = 0
        bytes = 0
        status = "Idle"
    }

    private func fetchOnce() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        return data
    }
}

struct DBZInstrumentsNetworkView: View {
    @StateObject private var viewModel = DBZInstrumentsNetworkViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 19: Instruments - Network")
                    .font(.title3.bold())

                Text("Normal: 1 request. Problema: burst concurrente de 20 requests.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Requests: \(viewModel.requests) | Bytes: \(viewModel.bytes) | Estado: \(viewModel.status)")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema (burst)") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: Network")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Network")
    }
}
