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
import Combine

struct DeliveryGate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var passed: Bool
}

@MainActor
final class DBZDeliveryViewModel: ObservableObject {
    @Published private(set) var gates: [DeliveryGate] = [
        DeliveryGate(title: "Build verde", description: "Compila en Debug y Release", passed: false),
        DeliveryGate(title: "Tests", description: "Unit + UI tests mínimos ejecutados", passed: false),
        DeliveryGate(title: "Crash-free", description: "No errores críticos en flujo principal", passed: false),
        DeliveryGate(title: "Feature flags", description: "Nueva feature protegida con flag", passed: false),
        DeliveryGate(title: "Observabilidad", description: "Logs y métricas básicas activas", passed: false),
        DeliveryGate(title: "Rollback", description: "Plan de rollback documentado", passed: false)
    ]

    @Published var releaseNoteInput: String = ""
    @Published private(set) var status: String = "Pendiente"

    var passedCount: Int {
        gates.filter { $0.passed }.count
    }

    var scorePercent: Int {
        guard !gates.isEmpty else { return 0 }
        return Int((Double(passedCount) / Double(gates.count) * 100.0).rounded())
    }

    var canShip: Bool {
        passedCount == gates.count && !releaseNoteInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// FUNC-GUIDE: toggleGate
    /// - Qué hace: marca/desmarca un quality gate del checklist.
    /// - Entrada: `gateID`.
    /// - Salida: recalcula estado general de release readiness.
    /// FUNC-GUIDE: toggleGate
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func toggleGate(_ gateID: UUID) {
        guard let index = gates.firstIndex(where: { $0.id == gateID }) else { return }
        gates[index].passed.toggle()
        print("[DELIVERY] gate=\(gates[index].title) passed=\(gates[index].passed)")
        recalculateStatus()
    }

    /// FUNC-GUIDE: generateReleaseSummary
    /// - Qué hace: construye un texto final con score, gates cumplidos y release notes.
    /// - Uso: copiar/pegar en PR, ticket o checklist de release.
    /// FUNC-GUIDE: generateReleaseSummary
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func generateReleaseSummary() -> String {
        let done = gates.filter { $0.passed }.map { "- ✅ \($0.title)" }
        let pending = gates.filter { !$0.passed }.map { "- ⏳ \($0.title)" }
        let notes = releaseNoteInput.trimmingCharacters(in: .whitespacesAndNewlines)

        return [
            "Release Readiness: \(scorePercent)%",
            "",
            "Done:",
            done.isEmpty ? "- (none)" : done.joined(separator: "\n"),
            "",
            "Pending:",
            pending.isEmpty ? "- (none)" : pending.joined(separator: "\n"),
            "",
            "Release Notes:",
            notes.isEmpty ? "- (empty)" : notes
        ].joined(separator: "\n")
    }

    /// Recalcula el estado visible del release en función de score y notas.
    /// FUNC-GUIDE: recalculateStatus
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func recalculateStatus() {
        if canShip {
            status = "Listo para release 🚀"
        } else if scorePercent >= 70 {
            status = "Casi listo: faltan algunos gates"
        } else {
            status = "Aún no listo"
        }
    }
}

/// Pantalla 12: cierre de ruta senior (CI/CD + release strategy + quality gates).
struct DBZDeliveryView: View {
    @StateObject private var viewModel = DBZDeliveryViewModel()
    @State private var summaryText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 12: Delivery Lab DBZ")
                    .font(.title2.bold())

                GroupBox("Qué aprendes aquí") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) CI/CD mindset con quality gates")
                        Text("2) Release readiness score")
                        Text("3) Feature flags + rollback como estrategia")
                        Text("4) Checklist real antes de enviar a producción")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Text("Score: \(viewModel.scorePercent)% (\(viewModel.passedCount)/\(viewModel.gates.count))")
                    .font(.headline)
                Text("Estado: \(viewModel.status)")
                    .foregroundStyle(viewModel.canShip ? .green : .orange)

                GroupBox("Quality Gates") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.gates) { gate in
                            Button {
                                viewModel.toggleGate(gate.id)
                            } label: {
                                HStack(alignment: .top) {
                                    Image(systemName: gate.passed ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(gate.passed ? .green : .secondary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(gate.title)
                                            .foregroundStyle(.primary)
                                        Text(gate.description)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                GroupBox("Release Notes") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $viewModel.releaseNoteInput)
                            .frame(height: 110)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.gray.opacity(0.25), lineWidth: 1)
                            )

                        HStack {
                            Button("Generar resumen") {
                                summaryText = viewModel.generateReleaseSummary()
                            }
                            .buttonStyle(.bordered)

                            Button("Ship decision") {
                                summaryText = viewModel.canShip
                                ? "✅ Ship: todos los gates y release notes listos"
                                : "❌ No Ship: faltan gates o release notes"
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                if !summaryText.isEmpty {
                    GroupBox("Salida") {
                        Text(summaryText)
                            .font(.caption.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DBZ Delivery")
    }
}
