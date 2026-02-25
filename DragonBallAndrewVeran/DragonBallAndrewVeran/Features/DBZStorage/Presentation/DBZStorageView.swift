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

@MainActor
final class DBZStorageViewModel: ObservableObject {
    @Published var favoriteWarriorInput: String = ""
    @Published var transformationInput: String = ""
    @Published var accessCodeInput: String = ""

    @Published private(set) var loadedFavoriteWarrior: String = "-"
    @Published private(set) var loadedTransformation: String = "-"
    @Published private(set) var loadedAccessCodeMasked: String = "-"
    @Published private(set) var statusMessage: String = "Idle"

    private let storage = DBZStorageManager.shared

    /// UserDefaults -> preferencias (datos no sensibles)
    /// FUNC-GUIDE: savePreferences
    /// - Qué hace: guarda guerrero y transformación favorita en UserDefaults.
    /// - Entrada: `favoriteWarriorInput`, `transformationInput`.
    /// - Salida: status + persistencia local no sensible.
    /// FUNC-GUIDE: savePreferences
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func savePreferences() {
        let warrior = favoriteWarriorInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let transformation = transformationInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !warrior.isEmpty, !transformation.isEmpty else {
            statusMessage = "Completa guerrero y transformación"
            return
        }

        let preferences = DBZProfilePreferences(favoriteWarrior: warrior, preferredTransformation: transformation)
        storage.savePreferences(preferences)
        statusMessage = "Preferencias guardadas en UserDefaults"
        print("[STORAGE][USERDEFAULTS] saved warrior=\(warrior), transformation=\(transformation)")
    }

    /// FUNC-GUIDE: loadPreferences
    /// - Qué hace: lee preferencias de UserDefaults y las adapta para UI.
    /// - Salida: actualiza labels cargadas en pantalla.
    /// FUNC-GUIDE: loadPreferences
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func loadPreferences() {
        let loaded = storage.loadPreferences()
        loadedFavoriteWarrior = loaded.favoriteWarrior.isEmpty ? "(vacío)" : loaded.favoriteWarrior
        loadedTransformation = loaded.preferredTransformation.isEmpty ? "(vacío)" : loaded.preferredTransformation
        statusMessage = "Preferencias cargadas desde UserDefaults"
        print("[STORAGE][USERDEFAULTS] loaded warrior=\(loadedFavoriteWarrior), transformation=\(loadedTransformation)")
    }

    /// FUNC-GUIDE: clearPreferences
    /// - Qué hace: elimina preferencias guardadas y reinicia estado visual.
    /// FUNC-GUIDE: clearPreferences
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func clearPreferences() {
        storage.clearPreferences()
        loadedFavoriteWarrior = "-"
        loadedTransformation = "-"
        statusMessage = "Preferencias eliminadas"
        print("[STORAGE][USERDEFAULTS] cleared")
    }

    /// Keychain -> secreto (dato sensible)
    /// FUNC-GUIDE: saveAccessCode
    /// - Qué hace: guarda un código sensible en Keychain.
    /// - Por qué Keychain: credenciales/secretos no deben ir en UserDefaults.
    /// FUNC-GUIDE: saveAccessCode
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func saveAccessCode() {
        let code = accessCodeInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !code.isEmpty else {
            statusMessage = "Escribe un access code"
            return
        }

        do {
            try storage.saveAccessCode(code)
            statusMessage = "Access code guardado en Keychain"
            print("[STORAGE][KEYCHAIN] saved access code")
        } catch {
            statusMessage = "Error guardando Keychain: \(error.localizedDescription)"
            print("[STORAGE][KEYCHAIN] save error=\(error.localizedDescription)")
        }
    }

    /// FUNC-GUIDE: loadAccessCode
    /// - Qué hace: intenta leer código de Keychain y mostrarlo enmascarado.
    /// - Detalle didáctico: usa optional binding para manejar valor ausente.
    /// FUNC-GUIDE: loadAccessCode
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func loadAccessCode() {
        do {
            let code = try storage.loadAccessCode()

            // Optional Binding + nil handling didactico.
            if let code, !code.isEmpty {
                loadedAccessCodeMasked = String(repeating: "*", count: max(4, code.count))
                statusMessage = "Access code leído desde Keychain"
            } else {
                loadedAccessCodeMasked = "(vacío)"
                statusMessage = "No existe access code en Keychain"
            }

            print("[STORAGE][KEYCHAIN] loaded code exists=\(code != nil)")
        } catch {
            statusMessage = "Error leyendo Keychain: \(error.localizedDescription)"
            print("[STORAGE][KEYCHAIN] load error=\(error.localizedDescription)")
        }
    }

    /// FUNC-GUIDE: deleteAccessCode
    /// - Qué hace: borra el secreto del Keychain y reinicia texto cargado.
    /// FUNC-GUIDE: deleteAccessCode
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func deleteAccessCode() {
        storage.deleteAccessCode()
        loadedAccessCodeMasked = "-"
        statusMessage = "Access code eliminado"
        print("[STORAGE][KEYCHAIN] deleted access code")
    }
}

/// Pantalla 6: Storage Lab (UserDefaults + Keychain + Singleton) con tema DBZ.
struct DBZStorageView: View {
    @StateObject private var viewModel = DBZStorageViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 6: Storage Lab DBZ")
                    .font(.title2.bold())

                GroupBox("Que aprendes aqui") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) UserDefaults: preferencias no sensibles")
                        Text("2) Keychain: secretos (access code)")
                        Text("3) Singleton: DBZStorageManager.shared")
                        Text("4) Optionals + guard + optional binding en lectura/escritura")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("UserDefaults (no sensible)") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Guerrero favorito (ej: Goku)", text: $viewModel.favoriteWarriorInput)
                            .textFieldStyle(.roundedBorder)

                        TextField("Transformación favorita (ej: Ultra Instinct)", text: $viewModel.transformationInput)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("Guardar") { viewModel.savePreferences() }
                            Button("Cargar") { viewModel.loadPreferences() }
                            Button("Limpiar") { viewModel.clearPreferences() }
                        }
                        .buttonStyle(.bordered)

                        Text("Loaded warrior: \(viewModel.loadedFavoriteWarrior)")
                        Text("Loaded transformation: \(viewModel.loadedTransformation)")
                            .foregroundStyle(.secondary)
                    }
                }

                GroupBox("Keychain (sensible)") {
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("Scouter access code", text: $viewModel.accessCodeInput)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("Guardar") { viewModel.saveAccessCode() }
                            Button("Cargar") { viewModel.loadAccessCode() }
                            Button("Eliminar") { viewModel.deleteAccessCode() }
                        }
                        .buttonStyle(.bordered)

                        Text("Loaded access code: \(viewModel.loadedAccessCodeMasked)")
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Estado: \(viewModel.statusMessage)")
                    .font(.headline)
            }
            .padding()
        }
        .navigationTitle("DBZ Storage")
        .onAppear {
            viewModel.loadPreferences()
            viewModel.loadAccessCode()
        }
    }
}
