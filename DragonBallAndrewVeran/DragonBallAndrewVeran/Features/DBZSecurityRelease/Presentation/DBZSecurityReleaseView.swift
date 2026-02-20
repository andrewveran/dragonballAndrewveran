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
import Foundation

@MainActor
final class DBZSecurityReleaseViewModel: ObservableObject {
    @Published var expectedFingerprint: String = "ABCD1234"
    @Published var serverFingerprint: String = ""
    @Published private(set) var pinningStatus: String = "No validado"

    @Published var userID: String = "goku_user"
    @Published var rolloutPercent: Double = 20
    @Published private(set) var featureEnabled: Bool = false
    @Published private(set) var releaseStatus: String = "Rollout no evaluado"

    @Published var killSwitch: Bool = false

    func validatePinning() {
        let expected = expectedFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        let incoming = serverFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !expected.isEmpty, !incoming.isEmpty else {
            pinningStatus = "Completa fingerprints"
            return
        }

        if expected == incoming {
            pinningStatus = "Pinning OK: certificado confiable"
            print("[SECURITY] pinning ok")
        } else {
            pinningStatus = "Pinning FAIL: certificado no coincide"
            print("[SECURITY] pinning fail")
        }
    }

    /// Simula feature flags por porcentaje de rollout.
    /// Hash estable por userID para que el resultado sea consistente.
    func evaluateRollout() {
        if killSwitch {
            featureEnabled = false
            releaseStatus = "Kill Switch activo: feature deshabilitada"
            print("[RELEASE] kill-switch disabled feature")
            return
        }

        let bucket = abs(userID.hashValue) % 100
        featureEnabled = bucket < Int(rolloutPercent)
        releaseStatus = "userBucket=\(bucket), rollout=\(Int(rolloutPercent))%"

        print("[RELEASE] evaluate user=\(userID) bucket=\(bucket) enabled=\(featureEnabled)")
    }

    func rollbackRelease() {
        rolloutPercent = 0
        featureEnabled = false
        releaseStatus = "Rollback aplicado: rollout 0%"
        print("[RELEASE] rollback to 0%")
    }
}

struct DBZSecurityReleaseView: View {
    @StateObject private var viewModel = DBZSecurityReleaseViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 11: Security + Release DBZ")
                    .font(.title2.bold())

                GroupBox("Qué aprendes aquí") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) Certificate pinning (simulado por fingerprint)")
                        Text("2) Feature flags con rollout porcentual")
                        Text("3) Kill switch para apagar feature en producción")
                        Text("4) Rollback rápido de release")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Security: Pinning") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Expected fingerprint", text: $viewModel.expectedFingerprint)
                            .textFieldStyle(.roundedBorder)
                        TextField("Server fingerprint", text: $viewModel.serverFingerprint)
                            .textFieldStyle(.roundedBorder)

                        Button("Validar pinning") {
                            viewModel.validatePinning()
                        }
                        .buttonStyle(.borderedProminent)

                        Text(viewModel.pinningStatus)
                            .font(.headline)
                    }
                }

                GroupBox("Release strategy: Feature Flags") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("User ID", text: $viewModel.userID)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Text("Rollout: \(Int(viewModel.rolloutPercent))%")
                            Slider(value: $viewModel.rolloutPercent, in: 0...100, step: 1)
                        }

                        Toggle("Kill Switch", isOn: $viewModel.killSwitch)

                        HStack {
                            Button("Evaluar rollout") {
                                viewModel.evaluateRollout()
                            }
                            Button("Rollback") {
                                viewModel.rollbackRelease()
                            }
                        }
                        .buttonStyle(.bordered)

                        Text("Feature enabled: \(viewModel.featureEnabled ? "SI" : "NO")")
                            .font(.headline)
                        Text(viewModel.releaseStatus)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DBZ Security")
    }
}
