import SwiftUI
import Combine

private final class DBZLeakyCycleBox {
    private var timer: Timer?
    private let payload = Data(count: 1_000_000)

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            _ = self.payload.count
        }
    }

    deinit {
        print("[Leaks] DBZLeakyCycleBox liberado")
    }
}

private final class DBZSafeBox {
    private var timer: Timer?
    private let payload = Data(count: 1_000_000)

    func startAndStop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            _ = self?.payload.count
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }

    deinit {
        print("[Leaks] DBZSafeBox liberado")
    }
}

@MainActor
private final class DBZInstrumentsLeaksViewModel: ObservableObject {
    @Published private(set) var leakCount = 0
    private static var leakedBoxes: [DBZLeakyCycleBox] = []

    func runNormal() {
        let box = DBZSafeBox()
        box.startAndStop()
    }

    func runLeak() {
        let box = DBZLeakyCycleBox()
        box.start()
        Self.leakedBoxes.append(box)
        leakCount = Self.leakedBoxes.count
    }

    func clearLeakBag() {
        Self.leakedBoxes.removeAll()
        leakCount = 0
    }
}

struct DBZInstrumentsLeaksView: View {
    @StateObject private var viewModel = DBZInstrumentsLeaksViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 14: Instruments - Leaks")
                    .font(.title3.bold())

                Text("Normal: crea y libera objetos. Leak: deja un ciclo de retencion con Timer.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Objetos retenidos intencionalmente: \(viewModel.leakCount)")
                    .font(.callout.monospacedDigit())

                Button("Escenario normal (sin leak)") {
                    viewModel.runNormal()
                }
                .buttonStyle(.borderedProminent)

                Button("Escenario con leak") {
                    viewModel.runLeak()
                }
                .buttonStyle(.bordered)

                Button("Liberar referencias globales") {
                    viewModel.clearLeakBag()
                }
                .buttonStyle(.bordered)

                Text("Instruments sugerido: Leaks + Allocations")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("DBZ Leaks")
    }
}
