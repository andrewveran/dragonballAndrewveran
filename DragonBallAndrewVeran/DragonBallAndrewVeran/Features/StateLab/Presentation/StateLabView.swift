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

/// ViewModel compartido para demostrar @StateObject (owner) y @ObservedObject (consumer).
final class StateLabViewModel: ObservableObject {
    @Published var sharedCount: Int = 0
    @Published var sharedText: String = ""

    /// FUNC-GUIDE: incrementSharedCount
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: incrementSharedCount
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func incrementSharedCount() {
        sharedCount += 1
        print("[STATE-LAB][VM] senzuBeans=\(sharedCount)")
    }

    /// FUNC-GUIDE: resetSharedCount
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: resetSharedCount
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func resetSharedCount() {
        sharedCount = 0
        print("[STATE-LAB][VM] senzuBeans reset")
    }
}

/// Pantalla 3: laboratorio de estado en SwiftUI.
struct StateLabView: View {
    // Estado local de la vista (value-type, no compartido fuera de esta vista).
    @State private var warriorName: String = ""
    @State private var localPowerLevel: Int = 0

    // Estado para ver diferencias entre .onAppear y .task(id:).
    @State private var appearRuns: Int = 0
    @State private var taskRuns: Int = 0
    @State private var taskTrigger: Int = 0

    // Owner del ViewModel en esta pantalla.
    @StateObject private var viewModel = StateLabViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pantalla 3: DBZ State Lab")
                    .font(.title2.bold())

                // 1) @State
                GroupBox("@State (estado local)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Usa @State cuando el dato pertenece solo a esta pantalla.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("Guerrero (ej: Goku)", text: $warriorName)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("+100 Power Local") { localPowerLevel += 100 }
                            Button("Reset Power Local") { localPowerLevel = 0 }
                        }
                        .buttonStyle(.bordered)

                        Text("warriorName: \(warriorName.isEmpty ? "(vacío)" : warriorName)")
                        Text("localPowerLevel: \(localPowerLevel)")
                            .foregroundStyle(.secondary)
                    }
                }

                // 2) @Binding
                GroupBox("@Binding (pasar referencia de estado a hijo)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("@Binding deja que la vista hija edite el estado del padre sin copiarlo.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        BindingChildCard(name: $warriorName, powerLevel: $localPowerLevel)
                    }
                }

                // 3) @StateObject + @ObservedObject
                GroupBox("@StateObject + @ObservedObject") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("El padre crea el ViewModel con @StateObject y el hijo lo observa con @ObservedObject.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ObservedObjectChildCard(viewModel: viewModel)
                    }
                }

                // 4) .onAppear vs .task
                GroupBox(".onAppear vs .task(id:)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(".onAppear corre al aparecer la vista. .task(id:) corre al aparecer y cada vez que cambia su id.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("onAppear runs: \(appearRuns)")
                        Text("task runs: \(taskRuns)")

                        Button("Re-ejecutar .task (simular nuevo entrenamiento)") {
                            taskTrigger += 1
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DBZ State Lab")
        .onAppear {
            appearRuns += 1
            print("[STATE-LAB][UI] onAppear run=\(appearRuns)")
        }
        .task(id: taskTrigger) {
            taskRuns += 1
            print("[STATE-LAB][UI] .task run=\(taskRuns) trigger=\(taskTrigger)")
        }
    }
}

/// Vista hija que edita estado del padre via @Binding.
private struct BindingChildCard: View {
    @Binding var name: String
    @Binding var powerLevel: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Editar guerrero desde hijo", text: $name)
                .textFieldStyle(.roundedBorder)

            Button("+500 power desde hijo") {
                powerLevel += 500
            }
            .buttonStyle(.bordered)

            Text("Hijo ve warriorName: \(name.isEmpty ? "(vacío)" : name)")
            Text("Hijo ve localPowerLevel: \(powerLevel)")
                .foregroundStyle(.secondary)
        }
    }
}

/// Vista hija que consume un ObservableObject creado por el padre.
private struct ObservedObjectChildCard: View {
    @ObservedObject var viewModel: StateLabViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Tecnica compartida (VM)", text: $viewModel.sharedText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("+1 Senzu") {
                    viewModel.incrementSharedCount()
                }
                Button("Reset Senzu") {
                    viewModel.resetSharedCount()
                }
            }
            .buttonStyle(.bordered)

            Text("senzuBeans(sharedCount): \(viewModel.sharedCount)")
            Text("sharedTechnique(sharedText): \(viewModel.sharedText.isEmpty ? "(vacío)" : viewModel.sharedText)")
                .foregroundStyle(.secondary)
        }
    }
}
