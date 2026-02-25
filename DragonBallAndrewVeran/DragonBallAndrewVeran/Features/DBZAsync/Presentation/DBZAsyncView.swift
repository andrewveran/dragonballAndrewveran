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

/// Pantalla 2: API real DBZ + async/await + Task + MainActor + Clean Architecture.
struct DBZAsyncView: View {
    @StateObject private var viewModel: DBZAsyncViewModel

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init() {
        // Composition root del modulo.
        let remote = DBZCharacterRemoteDataSourceImpl()
        let repository = DBZCharacterRepositoryImpl(remote: remote)
        let useCase = GetDBZCharacterByNameUseCaseImpl(repository: repository)
        _viewModel = StateObject(wrappedValue: DBZAsyncViewModel(useCase: useCase))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 2: API real + async/await")
                    .font(.title2.bold())

                GroupBox("Que aprendes aqui") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) Task: desde UI creas contexto async.")
                        Text("2) async/await: llamada secuencial facil de leer.")
                        Text("3) MainActor: estado UI seguro en hilo principal.")
                        Text("4) Clean Architecture con API real de Dragon Ball.")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Paso a paso del viaje") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("UI Button -> Task { await submit() }")
                        Text("ViewModel async -> UseCase.execute(name)")
                        Text("UseCase -> Repository")
                        Text("Repository -> Remote GET API DBZ")
                        Text("DTO -> Mapper -> Entity")
                        Text("Entity -> ViewData -> state loaded/error")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Text("Escribe un personaje DBZ (ej: Goku, Vegeta, Broly)")
                    .foregroundStyle(.secondary)

                TextField("Nombre", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()

                Button("Buscar") {
                    print("[UI][ASYNC] Tap en Buscar con input=\(viewModel.inputText)")

                    // Task crea contexto asíncrono desde UI para llamar funciones async.
                    Task {
                        await viewModel.submit()
                    }
                }
                .buttonStyle(.borderedProminent)

                stateView
            }
            .padding()
        }
        .navigationTitle("DBZ Async")
        .onChange(of: viewModel.state) { _, value in
            print("[UI][ASYNC] state cambió a \(describe(value))")
        }
    }

    @ViewBuilder
    private var stateView: some View {
        switch viewModel.state {
        case .idle:
            Text("Esperando búsqueda...")
                .foregroundStyle(.secondary)
        case .loading:
            HStack(spacing: 8) {
                ProgressView()
                Text("Consultando API real...")
            }
        case .loaded(let character):
            HStack(spacing: 12) {
                AsyncImage(url: character.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name).font(.headline)
                    Text("Raza: \(character.race)")
                    Text("Ki: \(character.ki)")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        case .error(let message):
            Text(message)
                .font(.headline)
                .foregroundStyle(.red)
        }
    }

    /// FUNC-GUIDE: describe
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func describe(_ state: DBZAsyncViewState) -> String {
        switch state {
        case .idle:
            return "idle"
        case .loading:
            return "loading"
        case .loaded(let data):
            return "loaded(name=\(data.name))"
        case .error(let message):
            return "error(message=\(message))"
        }
    }
}
