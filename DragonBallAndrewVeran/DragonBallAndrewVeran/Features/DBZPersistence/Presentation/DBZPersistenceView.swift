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

enum DBZPersistenceEngine: String, CaseIterable, Identifiable {
    case coreData = "Core Data"
    case swiftData = "SwiftData"

    var id: String { rawValue }
}

@MainActor
final class DBZPersistenceViewModel: ObservableObject {
    @Published var selectedEngine: DBZPersistenceEngine = .coreData
    @Published var warriorInput: String = ""
    @Published var minutesInput: String = ""

    @Published private(set) var sessions: [DBZTrainingSessionViewData] = []
    @Published private(set) var status: String = "Idle"

    private let coreDataStore = DBZCoreDataStore()
    private let swiftDataStore: DBZSwiftDataStore?

    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa ambos motores de persistencia (Core Data y SwiftData).
    /// - Caso especial: si SwiftData no está disponible, deja un estado informativo.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init() {
        swiftDataStore = try? DBZSwiftDataStore()
        if swiftDataStore == nil {
            status = "SwiftData no disponible en este entorno"
        }
    }

    /// FUNC-GUIDE: saveSession
    /// - Qué hace: valida input de UI y guarda una sesión usando el motor seleccionado.
    /// - Entradas: `warriorInput`, `minutesInput`, `selectedEngine`.
    /// - Salida: actualiza `status` y recarga `sessions` para refrescar la lista.
    /// FUNC-GUIDE: saveSession
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func saveSession() {
        let warrior = warriorInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !warrior.isEmpty else {
            status = "Escribe un guerrero"
            return
        }

        guard let minutes = Int(minutesInput), minutes > 0 else {
            status = "Minutos debe ser un numero mayor a 0"
            return
        }

        do {
            switch selectedEngine {
            case .coreData:
                try coreDataStore.saveSession(warrior: warrior, minutes: minutes)
            case .swiftData:
                guard let swiftDataStore else {
                    status = "SwiftData no disponible"
                    return
                }
                try swiftDataStore.saveSession(warrior: warrior, minutes: minutes)
            }

            status = "Guardado en \(selectedEngine.rawValue)"
            print("[PERSISTENCE][SAVE] engine=\(selectedEngine.rawValue) warrior=\(warrior) minutes=\(minutes)")
            loadSessions()
        } catch {
            status = "Error guardando: \(error.localizedDescription)"
            print("[PERSISTENCE][SAVE][ERROR] \(error.localizedDescription)")
        }
    }

    /// FUNC-GUIDE: loadSessions
    /// - Qué hace: lee sesiones persistidas desde Core Data o SwiftData.
    /// - Salida: rellena `sessions` (view data) y muestra estado de carga.
    /// FUNC-GUIDE: loadSessions
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func loadSessions() {
        do {
            switch selectedEngine {
            case .coreData:
                sessions = try coreDataStore.fetchSessions()
            case .swiftData:
                guard let swiftDataStore else {
                    sessions = []
                    status = "SwiftData no disponible"
                    return
                }
                sessions = try swiftDataStore.fetchSessions()
            }

            status = "Cargadas \(sessions.count) sesiones desde \(selectedEngine.rawValue)"
            print("[PERSISTENCE][LOAD] engine=\(selectedEngine.rawValue) count=\(sessions.count)")
        } catch {
            status = "Error cargando: \(error.localizedDescription)"
            print("[PERSISTENCE][LOAD][ERROR] \(error.localizedDescription)")
        }
    }

    /// FUNC-GUIDE: clearSessions
    /// - Qué hace: borra todas las sesiones del motor activo.
    /// - Salida: limpia tabla en UI y actualiza `status`.
    /// FUNC-GUIDE: clearSessions
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func clearSessions() {
        do {
            switch selectedEngine {
            case .coreData:
                try coreDataStore.clearAll()
            case .swiftData:
                guard let swiftDataStore else {
                    status = "SwiftData no disponible"
                    return
                }
                try swiftDataStore.clearAll()
            }

            sessions = []
            status = "Datos eliminados en \(selectedEngine.rawValue)"
            print("[PERSISTENCE][CLEAR] engine=\(selectedEngine.rawValue)")
        } catch {
            status = "Error limpiando: \(error.localizedDescription)"
            print("[PERSISTENCE][CLEAR][ERROR] \(error.localizedDescription)")
        }
    }
}

/// Pantalla 7: comparativa Core Data vs SwiftData con temática DBZ.
struct DBZPersistenceView: View {
    @StateObject private var viewModel = DBZPersistenceViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 7: Persistence Lab DBZ")
                    .font(.title2.bold())

                GroupBox("Que aprendes aqui") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) Persistencia estructurada con Core Data")
                        Text("2) Persistencia moderna con SwiftData")
                        Text("3) Mismo caso DBZ, distinto motor")
                        Text("4) Regla practica: usa repositorio para desacoplar motor")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Picker("Motor", selection: $viewModel.selectedEngine) {
                    ForEach(DBZPersistenceEngine.allCases) { engine in
                        Text(engine.rawValue).tag(engine)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedEngine) { _, _ in
                    viewModel.loadSessions()
                }

                GroupBox("Nueva sesión de entrenamiento") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Guerrero (ej: Goku)", text: $viewModel.warriorInput)
                            .textFieldStyle(.roundedBorder)

                        TextField("Minutos (ej: 45)", text: $viewModel.minutesInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("Guardar") { viewModel.saveSession() }
                            Button("Cargar") { viewModel.loadSessions() }
                            Button("Limpiar") { viewModel.clearSessions() }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Text("Estado: \(viewModel.status)")
                    .font(.headline)

                Text("Sesiones")
                    .font(.headline)

                if viewModel.sessions.isEmpty {
                    Text("No hay sesiones guardadas")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.sessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.warrior)
                                .font(.headline)
                            Text("Minutos: \(session.minutes)")
                            Text("Motor: \(session.source)")
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DBZ Persistence")
        .onAppear {
            viewModel.loadSessions()
        }
    }
}
