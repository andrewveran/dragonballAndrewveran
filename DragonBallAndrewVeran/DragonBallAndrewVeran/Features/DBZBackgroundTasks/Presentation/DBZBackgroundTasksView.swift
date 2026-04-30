import SwiftUI

#if canImport(BackgroundTasks)
import BackgroundTasks

private let dbzBackgroundTasksAvailable = true
#else
private let dbzBackgroundTasksAvailable = false
#endif

@MainActor
private final class DBZBackgroundTasksViewModel: ObservableObject {
    @Published private(set) var status = "Idle"
    @Published private(set) var pendingJobs = 0
    @Published private(set) var logs: [String] = []

    func scheduleRefresh() {
        pendingJobs += 1
        status = "Refresh solicitado"
        logs.insert("Se agenda un refresh para sincronizar entrenamientos.", at: 0)

        #if canImport(BackgroundTasks)
        let request = BGAppRefreshTaskRequest(identifier: "com.andrewveran.dbz.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        logs.insert("BGTaskScheduler disponible. Request preparado con earliestBeginDate +15m.", at: 0)
        _ = request
        #else
        logs.insert("BackgroundTasks framework no disponible en este target.", at: 0)
        #endif
    }

    func runSimulatedBackgroundWork() {
        status = "Ejecutando sync simulada..."
        logs.insert("Inicio de trabajo en background: pull de datos pendientes.", at: 0)

        Task {
            try? await Task.sleep(for: .milliseconds(1100))
            pendingJobs = max(0, pendingJobs - 1)
            status = "Trabajo completado"
            logs.insert("Fin de background sync. Cola pendiente actualizada.", at: 0)
        }
    }

    func reset() {
        status = "Idle"
        pendingJobs = 0
        logs = []
    }
}

struct DBZBackgroundTasksView: View {
    @StateObject private var viewModel = DBZBackgroundTasksViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 28: Background Tasks Lab")
                    .font(.title3.bold())

                Text("Estudia el flujo de agendar trabajo diferido, mantener una cola pendiente y ejecutar una sincronizacion simulada fuera del flujo inmediato de UI.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                GroupBox("Estado del framework") {
                    Text(dbzBackgroundTasksAvailable
                         ? "BackgroundTasks framework esta disponible. Para scheduling real faltan identificadores en Info.plist y registro en App lifecycle."
                         : "BackgroundTasks framework no esta disponible en este target.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text("Pending jobs: \(viewModel.pendingJobs)")
                    .font(.callout.monospaced())

                Text("Estado: \(viewModel.status)")
                    .font(.callout.monospaced())

                HStack {
                    Button("Agendar refresh") {
                        viewModel.scheduleRefresh()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Ejecutar trabajo simulado") {
                        viewModel.runSimulatedBackgroundWork()
                    }
                    .buttonStyle(.bordered)
                }

                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Logs")
                        .font(.headline)

                    ForEach(viewModel.logs.indices, id: \.self) { index in
                        Text(viewModel.logs[index])
                            .font(.footnote.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DBZ Background")
    }
}
