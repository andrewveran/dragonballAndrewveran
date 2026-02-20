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
import SwiftUI
import Foundation
import Combine

/// Modelo Sendable para mover datos entre tareas concurrentes de forma segura.
struct FighterPower: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let power: Int
}

/// Actor para guardar logs sin data races.
actor ScouterLogStore {
    private var events: [String] = []

    func add(_ message: String) {
        events.append(message)
    }

    func all() -> [String] {
        events
    }

    func clear() {
        events.removeAll()
    }
}

@MainActor
final class DBZConcurrencyViewModel: ObservableObject {
    @Published private(set) var stateText: String = "Idle"
    @Published private(set) var powers: [FighterPower] = []
    @Published private(set) var detachedInfo: String = "Aun no se ejecuta Task.detached"
    @Published private(set) var mainQueueInfo: String = "Sin update por DispatchQueue.main"

    private var currentTask: Task<Void, Never>?
    private let logStore = ScouterLogStore()

    // MARK: - Public Actions

    func runSequentialScan() {
        cancelCurrentTask()

        currentTask = Task {
            await resetForNewRun(title: "Running: Secuencial")

            do {
                let goku = try await fetchPower(for: "Goku")
                let vegeta = try await fetchPower(for: "Vegeta")
                let broly = try await fetchPower(for: "Broly")

                powers = [goku, vegeta, broly]
                stateText = "Completado (secuencial)"
                await logStore.add("[SEQUENTIAL] Finished with \(powers.count) fighters")
            } catch is CancellationError {
                stateText = "Cancelado (secuencial)"
                await logStore.add("[SEQUENTIAL] Cancelled")
            } catch {
                stateText = "Error (secuencial): \(error.localizedDescription)"
                await logStore.add("[SEQUENTIAL] Error: \(error.localizedDescription)")
            }
        }
    }

    func runAsyncLetScan() {
        cancelCurrentTask()

        currentTask = Task {
            await resetForNewRun(title: "Running: async let")

            do {
                async let goku = fetchPower(for: "Goku")
                async let vegeta = fetchPower(for: "Vegeta")
                async let broly = fetchPower(for: "Broly")

                let result = try await [goku, vegeta, broly]
                powers = result
                stateText = "Completado (async let)"
                await logStore.add("[ASYNC LET] Finished with \(powers.count) fighters")
            } catch is CancellationError {
                stateText = "Cancelado (async let)"
                await logStore.add("[ASYNC LET] Cancelled")
            } catch {
                stateText = "Error (async let): \(error.localizedDescription)"
                await logStore.add("[ASYNC LET] Error: \(error.localizedDescription)")
            }
        }
    }

    func runTaskGroupScan() {
        cancelCurrentTask()

        currentTask = Task {
            await resetForNewRun(title: "Running: TaskGroup")

            do {
                let names = ["Goku", "Vegeta", "Broly", "Gohan"]
                let result = try await withThrowingTaskGroup(of: FighterPower.self) { group in
                    for name in names {
                        group.addTask {
                            try await self.fetchPower(for: name)
                        }
                    }

                    var collected: [FighterPower] = []
                    for try await fighter in group {
                        collected.append(fighter)
                    }
                    return collected.sorted { $0.power > $1.power }
                }

                powers = result
                stateText = "Completado (TaskGroup)"
                await logStore.add("[TASK GROUP] Finished with \(powers.count) fighters")
            } catch is CancellationError {
                stateText = "Cancelado (TaskGroup)"
                await logStore.add("[TASK GROUP] Cancelled")
            } catch {
                stateText = "Error (TaskGroup): \(error.localizedDescription)"
                await logStore.add("[TASK GROUP] Error: \(error.localizedDescription)")
            }
        }
    }

    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }

    func runDetachedDemo() {
        Task.detached(priority: .background) {
            let isMainAtStart = Thread.isMainThread
            try? await Task.sleep(nanoseconds: 400_000_000)
            let isMainAtEnd = Thread.isMainThread

            await MainActor.run {
                print("[CONCURRENCY][DETACHED] startMain=\(isMainAtStart) endMain=\(isMainAtEnd)")
            }
        }

        detachedInfo = "Task.detached lanzada (revisa consola)"
    }

    func runDispatchQueueMainDemo() {
        DispatchQueue.main.async {
            self.mainQueueInfo = "Update hecho con DispatchQueue.main.async"
            print("[CONCURRENCY][GCD] UI update via DispatchQueue.main.async")
        }
    }

    func loadLogs() {
        Task {
            let events = await logStore.all()
            print("[CONCURRENCY][LOGS] \(events)")
        }
    }

    // MARK: - Internals

    private func resetForNewRun(title: String) async {
        stateText = title
        powers = []
        await logStore.clear()
        await logStore.add("[RUN] \(title)")
    }

    private func fetchPower(for name: String) async throws -> FighterPower {
        try Task.checkCancellation()

        let delayByName: [String: UInt64] = [
            "Goku": 700_000_000,
            "Vegeta": 500_000_000,
            "Broly": 900_000_000,
            "Gohan": 600_000_000
        ]

        let powerByName: [String: Int] = [
            "Goku": 9000,
            "Vegeta": 8500,
            "Broly": 12000,
            "Gohan": 8000
        ]

        let delay = delayByName[name] ?? 400_000_000
        try await Task.sleep(nanoseconds: delay)
        try Task.checkCancellation()

        let power = powerByName[name] ?? 1000
        await logStore.add("[FETCH] \(name)=\(power)")
        print("[CONCURRENCY][FETCH] \(name) -> \(power)")

        return FighterPower(name: name, power: power)
    }
}

struct DBZConcurrencyView: View {
    @StateObject private var viewModel = DBZConcurrencyViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 5: Concurrencia DBZ")
                    .font(.title2.bold())

                GroupBox("Que aprendes aqui") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) Secuencial vs async let vs TaskGroup")
                        Text("2) Cancelacion cooperativa de tareas")
                        Text("3) Task.detached y diferencia de contexto")
                        Text("4) MainActor vs DispatchQueue.main")
                        Text("5) Actor + Sendable para seguridad de datos")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Text("Estado: \(viewModel.stateText)")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    Button("Run Secuencial") { viewModel.runSequentialScan() }
                    Button("Run async let") { viewModel.runAsyncLetScan() }
                    Button("Run TaskGroup") { viewModel.runTaskGroupScan() }
                    Button("Cancelar tarea actual") { viewModel.cancelCurrentTask() }
                }
                .buttonStyle(.borderedProminent)

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Button("Demo Task.detached") { viewModel.runDetachedDemo() }
                        .buttonStyle(.bordered)

                    Text(viewModel.detachedInfo)
                        .foregroundStyle(.secondary)

                    Button("Demo DispatchQueue.main") { viewModel.runDispatchQueueMainDemo() }
                        .buttonStyle(.bordered)

                    Text(viewModel.mainQueueInfo)
                        .foregroundStyle(.secondary)
                }

                Divider()

                Text("Resultados de power scan")
                    .font(.headline)

                if viewModel.powers.isEmpty {
                    Text("Sin resultados aun")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.powers) { fighter in
                        HStack {
                            Text(fighter.name)
                            Spacer()
                            Text("Power: \(fighter.power)")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Button("Imprimir logs internos") {
                    viewModel.loadLogs()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("DBZ Concurrency")
    }
}
