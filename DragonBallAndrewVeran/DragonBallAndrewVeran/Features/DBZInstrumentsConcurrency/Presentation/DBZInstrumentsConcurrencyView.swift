import Foundation
import SwiftUI
import Combine

private actor DBZSafeCounter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}

@MainActor
private final class DBZInstrumentsConcurrencyViewModel: ObservableObject {
    @Published private(set) var status = "Idle"
    @Published private(set) var elapsedMs = 0

    private var stressChecksum = 0

    func runNormal() {
        status = "Ejecutando actor + limite de tareas..."
        Task {
            let start = Date()
            let counter = DBZSafeCounter()

            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<8 {
                    group.addTask {
                        for _ in 0..<600 {
                            await counter.increment()
                        }
                    }
                }
            }

            let total = await counter.value
            elapsedMs = Int(Date().timeIntervalSince(start) * 1_000)
            status = "Normal completado (total: \(total))"
        }
    }

    func runProblem() {
        status = "Lanzando explosion de tareas..."
        Task {
            let start = Date()
            var checksum = 0

            await withTaskGroup(of: Int.self) { group in
                for taskID in 0..<1_500 {
                    group.addTask {
                        var local = 0
                        for spin in 0..<300 {
                            local += (taskID + spin) % 7
                        }
                        return local
                    }
                }

                for await localValue in group {
                    checksum += localValue
                }
            }

            elapsedMs = Int(Date().timeIntervalSince(start) * 1_000)
            stressChecksum = checksum
            status = "Problema completado (checksum: \(checksum))"
        }
    }

    func reset() {
        elapsedMs = 0
        stressChecksum = 0
        status = "Idle"
    }
}

struct DBZInstrumentsConcurrencyView: View {
    @StateObject private var viewModel = DBZInstrumentsConcurrencyViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 22: Instruments - Concurrency")
                    .font(.title3.bold())

                Text("Normal: pocas tareas + actor. Problema: explosion de tareas + contencion de lock.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Estado: \(viewModel.status) | Tiempo: \(viewModel.elapsedMs) ms")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: Swift Concurrency / Thread State")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Concurrency")
    }
}
