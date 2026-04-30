import Combine
import SwiftUI

#if canImport(Apollo)
import Apollo

private let dbzApolloSDKAvailable = true
#else
private let dbzApolloSDKAvailable = false
#endif

private struct DBZGraphQLCharacter: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let title: String
}

private struct DBZGraphQLErrorPayload: Decodable, Equatable {
    let message: String
}

private struct DBZGraphQLCharactersEnvelope: Decodable {
    let data: DBZGraphQLCharactersData?
    let errors: [DBZGraphQLErrorPayload]?
}

private struct DBZGraphQLCharactersData: Decodable {
    let characters: [DBZGraphQLCharacter]
}

private protocol DBZGraphQLCharacterRepository {
    func searchCharacters(name: String) async throws -> [DBZGraphQLCharacter]
}

private enum DBZGraphQLRepositoryError: LocalizedError {
    case invalidResponse
    case graphQLErrors([DBZGraphQLErrorPayload])

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "La respuesta GraphQL no tiene el formato esperado."
        case .graphQLErrors(let errors):
            return errors.map(\.message).joined(separator: " | ")
        }
    }
}

private struct DBZDokkanGraphQLRepository: DBZGraphQLCharacterRepository {
    private let endpoint = URL(string: "https://dokkanapi.azurewebsites.net/graphql")!

    func searchCharacters(name: String) async throws -> [DBZGraphQLCharacter] {
        let query = """
        query SearchCharacters($name: String!) {
          characters(name: $name) {
            id
            name
            title
          }
        }
        """

        let body = DBZGraphQLRequestBody(
            query: query,
            variables: ["name": name]
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw DBZGraphQLRepositoryError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(DBZGraphQLCharactersEnvelope.self, from: data)

        if let errors = decoded.errors, !errors.isEmpty {
            throw DBZGraphQLRepositoryError.graphQLErrors(errors)
        }

        guard let characters = decoded.data?.characters else {
            throw DBZGraphQLRepositoryError.invalidResponse
        }

        return characters
    }
}

private struct DBZGraphQLRequestBody: Encodable {
    let query: String
    let variables: [String: String]
}

private protocol DBZSearchGraphQLCharactersUseCase {
    func execute(name: String) async throws -> [DBZGraphQLCharacter]
}

private struct DBZSearchGraphQLCharactersUseCaseImpl: DBZSearchGraphQLCharactersUseCase {
    let repository: any DBZGraphQLCharacterRepository

    func execute(name: String) async throws -> [DBZGraphQLCharacter] {
        try await repository.searchCharacters(name: name)
    }
}

@MainActor
private final class DBZGraphQLApolloViewModel: ObservableObject {
    @Published var queryText = "broly"
    @Published private(set) var status = "Idle"
    @Published private(set) var characters: [DBZGraphQLCharacter] = []

    private let useCase: any DBZSearchGraphQLCharactersUseCase

    init(useCase: any DBZSearchGraphQLCharactersUseCase) {
        self.useCase = useCase
    }

    func search() {
        let trimmed = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            status = "Escribe un nombre para consultar GraphQL."
            characters = []
            return
        }

        status = "Consultando GraphQL..."
        characters = []

        Task {
            do {
                let result = try await useCase.execute(name: trimmed)
                characters = result
                status = "Resultado: \(result.count) personajes"
            } catch {
                status = "Error: \(error.localizedDescription)"
            }
        }
    }
}

struct DBZGraphQLApolloView: View {
    @StateObject private var viewModel: DBZGraphQLApolloViewModel

    init() {
        let repository = DBZDokkanGraphQLRepository()
        let useCase = DBZSearchGraphQLCharactersUseCaseImpl(repository: repository)
        _viewModel = StateObject(wrappedValue: DBZGraphQLApolloViewModel(useCase: useCase))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 26: GraphQL + Apollo Lab")
                    .font(.title3.bold())

                Text("Consulta un endpoint GraphQL real y compara la idea de pedir solo los campos que la UI necesita.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                GroupBox("Endpoint real") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("POST https://dokkanapi.azurewebsites.net/graphql")
                        Text("Query: characters(name: $name) { id name title }")
                    }
                    .font(.footnote.monospaced())
                }

                GroupBox("Apollo en este lab") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(dbzApolloSDKAvailable
                             ? "Apollo SDK esta disponible en el target."
                             : "Apollo SDK aun no esta agregado al target. La consulta corre con GraphQL sobre HTTP y la pantalla queda lista para migrar a Apollo + codegen.")
                        Text("Paso siguiente senior: agregar package Apollo, descargar schema y generar tipos para dejar de mapear JSON manualmente.")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                TextField("Buscar por nombre. Ej: broly, raditz, cooler", text: $viewModel.queryText)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                HStack {
                    Button("Consultar GraphQL") {
                        viewModel.search()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Ejemplo Raditz") {
                        viewModel.queryText = "raditz"
                        viewModel.search()
                    }
                    .buttonStyle(.bordered)
                }

                Text(viewModel.status)
                    .font(.callout.monospaced())

                ForEach(viewModel.characters) { character in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(character.name)
                            .font(.headline)
                        Text(character.title)
                            .foregroundStyle(.secondary)
                        Text("id: \(character.id)")
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("DBZ GraphQL")
    }
}
