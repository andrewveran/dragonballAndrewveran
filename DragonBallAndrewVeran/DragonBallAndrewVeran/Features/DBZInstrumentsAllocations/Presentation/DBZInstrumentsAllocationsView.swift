import SwiftUI
import Combine

@MainActor
private final class DBZInstrumentsAllocationsViewModel: ObservableObject {
    @Published private(set) var keptBlocks = 0
    @Published private(set) var estimatedMB = 0

    private var retainedData: [Data] = []

    func runNormal() {
        var temp: [Data] = []
        for _ in 0..<12 {
            temp.append(Data(count: 1_000_000))
        }
        temp.removeAll()
        refreshMetrics()
    }

    func runProblem() {
        for _ in 0..<12 {
            retainedData.append(Data(count: 1_000_000))
        }
        refreshMetrics()
    }

    func clear() {
        retainedData.removeAll()
        refreshMetrics()
    }

    private func refreshMetrics() {
        keptBlocks = retainedData.count
        estimatedMB = retainedData.reduce(0) { $0 + $1.count } / 1_000_000
    }
}

struct DBZInstrumentsAllocationsView: View {
    @StateObject private var viewModel = DBZInstrumentsAllocationsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 15: Instruments - Allocations")
                    .font(.title3.bold())

                Text("Normal: memoria temporal. Problema: memoria retenida en arreglo.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Bloques retenidos: \(viewModel.keptBlocks) | Memoria estimada: \(viewModel.estimatedMB) MB")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal (temporal)") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema (retener memoria)") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Button("Limpiar") {
                    viewModel.clear()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: Allocations")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Allocations")
    }
}
