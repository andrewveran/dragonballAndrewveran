import Combine
import SwiftUI

private struct DBZFighterProfile: Equatable {
    let name: String
    let powerLevel: Int
    let source: String
}

private protocol DBZFighterProfileRepository {
    func fetchProfile(for fighter: String) async throws -> DBZFighterProfile
}

private struct DBZLiveFighterProfileRepository: DBZFighterProfileRepository {
    func fetchProfile(for fighter: String) async throws -> DBZFighterProfile {
        try await Task.sleep(for: .milliseconds(350))
        return DBZFighterProfile(name: fighter.capitalized, powerLevel: 9001, source: "live")
    }
}

private struct DBZMockFighterProfileRepository: DBZFighterProfileRepository {
    func fetchProfile(for fighter: String) async throws -> DBZFighterProfile {
        DBZFighterProfile(name: fighter.capitalized, powerLevel: 1500, source: "mock")
    }
}

private protocol DBZFetchFighterProfileUseCase {
    func execute(fighter: String) async throws -> DBZFighterProfile
}

private struct DBZFetchFighterProfileUseCaseImpl: DBZFetchFighterProfileUseCase {
    let repository: any DBZFighterProfileRepository

    func execute(fighter: String) async throws -> DBZFighterProfile {
        try await repository.fetchProfile(for: fighter)
    }
}

private enum DBZAppEnvironment: String, CaseIterable, Identifiable {
    case live
    case mock

    var id: String { rawValue }
}

private struct DBZAppContainer {
    let environment: DBZAppEnvironment

    func makeProfileUseCase() -> any DBZFetchFighterProfileUseCase {
        switch environment {
        case .live:
            return DBZFetchFighterProfileUseCaseImpl(repository: DBZLiveFighterProfileRepository())
        case .mock:
            return DBZFetchFighterProfileUseCaseImpl(repository: DBZMockFighterProfileRepository())
        }
    }
}

@MainActor
private final class DBZDIContainerViewModel: ObservableObject {
    @Published var environment: DBZAppEnvironment = .live
    @Published var fighterName = "goku"
    @Published private(set) var status = "Idle"
    @Published private(set) var profile: DBZFighterProfile?

    func loadProfile() {
        let container = DBZAppContainer(environment: environment)
        let useCase = container.makeProfileUseCase()
        let fighter = fighterName

        status = "Resolviendo dependencias en \(environment.rawValue)..."
        profile = nil

        Task {
            do {
                let result = try await useCase.execute(fighter: fighter)
                profile = result
                status = "Perfil cargado desde \(result.source)"
            } catch {
                status = "Error: \(error.localizedDescription)"
            }
        }
    }
}

struct DBZDIContainerView: View {
    @StateObject private var viewModel = DBZDIContainerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 24: DI Container + Module Assembly")
                    .font(.title3.bold())

                Text("Practica composition root, factories y cambio de implementaciones sin tocar la view.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Environment", selection: $viewModel.environment) {
                    ForEach(DBZAppEnvironment.allCases) { environment in
                        Text(environment.rawValue.capitalized).tag(environment)
                    }
                }
                .pickerStyle(.segmented)

                TextField("fighter", text: $viewModel.fighterName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button("Resolver modulo y cargar perfil") {
                    viewModel.loadProfile()
                }
                .buttonStyle(.borderedProminent)

                Text(viewModel.status)
                    .font(.callout.monospaced())

                if let profile = viewModel.profile {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resultado")
                            .font(.headline)
                        Text("Name: \(profile.name)")
                        Text("Power Level: \(profile.powerLevel)")
                        Text("Source: \(profile.source)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("DBZ DI")
    }
}
