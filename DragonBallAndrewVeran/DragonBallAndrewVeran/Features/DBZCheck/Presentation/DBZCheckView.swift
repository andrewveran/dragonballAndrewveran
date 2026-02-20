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

/// Vista de la Pantalla 1.
/// Muestra el viaje del dato desde UI hasta red y de vuelta.
struct DBZCheckView: View {
    /// StateObject: la vista crea y conserva el ciclo de vida del ViewModel.
    @StateObject private var viewModel: DBZCheckViewModel

    /// Retenemos el logger fuerte en la vista para evitar que se libere.
    ///
    /// Senior interview note:
    /// - Si solo se pasa a una propiedad weak, puede deallocarse y perder logs.
    private let logger: PrintNetworkClientDelegate

    init() {
        // Composition root del modulo: wiring explicito de dependencias.
        let logger = PrintNetworkClientDelegate()
        let client = URLSessionNetworkClient(delegate: logger)
        let remote = DBZCheckRemoteDataSourceImpl(client: client)
        let repository = DBZCheckRepositoryImpl(remote: remote)
        let useCase = CheckDBZAnswerUseCaseImpl(repository: repository)

        _viewModel = StateObject(wrappedValue: DBZCheckViewModel(useCase: useCase))
        self.logger = logger
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 1: Viaje del dato (Mock POST)")
                    .font(.title2.bold())

                GroupBox("Que aprendes aqui") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) MVVM: la vista no hace red, solo habla con el ViewModel.")
                        Text("2) Clean Architecture: UseCase -> Repository -> Remote -> Network.")
                        Text("3) Combine: el resultado vuelve como publisher y actualiza el estado.")
                        Text("4) Estado UI: idle/loading/success/failure.")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Paso a paso del viaje") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("UI -> ViewModel.submit()")
                        Text("ViewModel -> UseCase.execute()")
                        Text("UseCase -> Repository.checkAnswer()")
                        Text("Repository -> Remote.POST")
                        Text("Remote -> NetworkClient")
                        Text("Response -> ViewModel.state")
                        Text("State -> UI (verde/rojo)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Text("Escribe exactamente \"Goku\" y presiona enviar.")
                    .foregroundStyle(.secondary)

                // Two-way binding entre TextField y ViewModel.inputText.
                TextField("Ej: Goku", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button("Enviar") {
                    print("[UI] Tap en Enviar con input=\(viewModel.inputText)")
                    viewModel.submit()
                }
                .buttonStyle(.borderedProminent)

                // Renderiza el estado actual.
                stateView
            }
            .padding()
        }
        .navigationTitle("DBZ Check")
        .onChange(of: viewModel.state) { _, newValue in
            print("[UI] state cambio a \(stateDescription(newValue))")
        }
        .onAppear {
            // Mantiene referencia activa del logger y deja traza visual del ciclo de vida.
            _ = logger
            print("[UI] DBZCheckView onAppear")
        }
    }

    @ViewBuilder
    private var stateView: some View {
        switch viewModel.state {
        case .idle:
            Text("Esperando input...")
                .foregroundStyle(.secondary)
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                Text("Enviando request...")
            }
        case .success(let message):
            Text(message)
                .font(.headline)
                .foregroundStyle(.green)
        case .failure(let message):
            Text(message)
                .font(.headline)
                .foregroundStyle(.red)
        }
    }

    /// Helper para logs legibles del estado.
    private func stateDescription(_ state: DBZCheckViewState) -> String {
        switch state {
        case .idle:
            return "idle"
        case .loading:
            return "loading"
        case .success(let message):
            return "success(message=\(message))"
        case .failure(let message):
            return "failure(message=\(message))"
        }
    }
}
