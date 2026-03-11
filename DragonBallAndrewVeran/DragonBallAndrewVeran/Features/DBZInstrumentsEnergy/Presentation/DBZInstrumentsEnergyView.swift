import SwiftUI
import Combine

@MainActor
private final class DBZInstrumentsEnergyViewModel: ObservableObject {
    @Published private(set) var mode = "Idle"
    @Published private(set) var ticks = 0

    private var timer: Timer?

    func runNormal() {
        stop()
        mode = "Normal (1 Hz)"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.ticks += 1
        }
    }

    func runProblem() {
        stop()
        mode = "Problema (60 Hz + CPU)"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.ticks += 1
            self.doCpuWork()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        mode = "Idle"
    }

    private func doCpuWork() {
        var acc = 0
        for index in 0..<45_000 {
            acc += index % 9
        }
        _ = acc
    }
}

struct DBZInstrumentsEnergyView: View {
    @StateObject private var viewModel = DBZInstrumentsEnergyViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 21: Instruments - Energy Log")
                    .font(.title3.bold())

                Text("Normal: timer de baja frecuencia. Problema: timer 60 Hz + carga de CPU sostenida.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Modo: \(viewModel.mode) | Ticks: \(viewModel.ticks)")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario problema") {
                    viewModel.runProblem()
                }
                .buttonStyle(.bordered)

                Button("Detener") {
                    viewModel.stop()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: Energy Log")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Energy")
        .onDisappear {
            viewModel.stop()
        }
    }
}
