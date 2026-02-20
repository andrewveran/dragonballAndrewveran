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

private enum DBZContainerMode: String, CaseIterable, Identifiable {
    case list = "List"
    case lazyVStack = "LazyVStack"

    var id: String { rawValue }
}

struct DBZUIFlowView: View {
    @State private var mode: DBZContainerMode = .list
    @State private var query: String = ""
    @State private var appearCount: Int = 0
    @State private var taskCount: Int = 0
    @State private var taskTrigger: Int = 0
    @State private var mainActorMessage: String = "Sin update"

    private let fighters: [String] = [
        "Goku", "Vegeta", "Broly", "Gohan", "Piccolo", "Trunks", "Frieza", "Cell", "Jiren", "Beerus"
    ]

    private var filteredFighters: [String] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return fighters }
        return fighters.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pantalla 9: UI Flow DBZ")
                .font(.title2.bold())

            GroupBox("Qué aprendes aquí") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("1) List vs LazyVStack")
                    Text("2) .onAppear vs .task(id:)")
                    Text("3) MainActor vs DispatchQueue.main")
                    Text("4) Filtro simple con estado UI")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Picker("Container", selection: $mode) {
                ForEach(DBZContainerMode.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)

            TextField("Filtrar guerrero", text: $query)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text("onAppear: \(appearCount)")
                Text("task: \(taskCount)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Button("Re-ejecutar task") { taskTrigger += 1 }
                Button("Update con MainActor") {
                    Task {
                        await MainActor.run {
                            mainActorMessage = "UI actualizada con MainActor.run"
                            print("[UI-FLOW] MainActor.run update")
                        }
                    }
                }
                Button("Update con DispatchQueue.main") {
                    DispatchQueue.main.async {
                        mainActorMessage = "UI actualizada con DispatchQueue.main"
                        print("[UI-FLOW] DispatchQueue.main update")
                    }
                }
            }
            .buttonStyle(.bordered)

            Text(mainActorMessage)
                .foregroundStyle(.secondary)

            if mode == .list {
                List(filteredFighters, id: \.self) { fighter in
                    Text(fighter)
                }
                .frame(height: 260)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredFighters, id: \.self) { fighter in
                            Text(fighter)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .frame(height: 260)
            }
        }
        .padding()
        .navigationTitle("DBZ UI Flow")
        .onAppear {
            appearCount += 1
            print("[UI-FLOW] onAppear count=\(appearCount)")
        }
        .task(id: taskTrigger) {
            taskCount += 1
            print("[UI-FLOW] task count=\(taskCount), trigger=\(taskTrigger)")
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
    }
}
