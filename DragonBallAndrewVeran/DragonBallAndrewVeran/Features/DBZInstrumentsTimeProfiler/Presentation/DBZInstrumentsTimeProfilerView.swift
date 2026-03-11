import SwiftUI
import Combine

@MainActor
private final class DBZInstrumentsTimeProfilerViewModel: ObservableObject {
    @Published private(set) var status = "Idle"
    @Published private(set) var elapsedMs = 0

    func runNormal() {
        status = "Procesando en background..."
        let start = Date()

        Task.detached {
            _ = Self.heavyComputation(repetitions: 8_000_000)
            let elapsed = Int(Date().timeIntervalSince(start) * 1_000)

            await MainActor.run {
                self.elapsedMs = elapsed
                self.status = "Listo (background)"
            }
        }
    }

    func runProblem() {
        status = "Procesando en main thread..."
        let start = Date()
        _ = Self.heavyComputation(repetitions: 8_000_000)
        elapsedMs = Int(Date().timeIntervalSince(start) * 1_000)
        status = "Listo (main bloqueado)"
    }

    nonisolated private static func heavyComputation(repetitions: Int) -> Int {
        var acc = 0
        for index in 0..<repetitions {
            acc += (index % 7) * (index % 3)
        }
        return acc
    }
}

struct DBZInstrumentsTimeProfilerView: View {
    @StateObject private var viewModel = DBZInstrumentsTimeProfilerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 17: Instruments - Time Profiler")
                    .font(.title3.bold())

                Text("Normal: CPU fuera del hilo principal. Problema: calculo pesado en main thread.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Estado: \(viewModel.status) | Tiempo: \(viewModel.elapsedMs) ms")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal (background)") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema (main thread)") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: Time Profiler")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Time Profiler")
    }
}
