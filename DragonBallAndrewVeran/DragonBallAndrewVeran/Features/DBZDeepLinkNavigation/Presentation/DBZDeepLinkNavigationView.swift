import Combine
import SwiftUI

private enum DBZDeepLinkDestination: Hashable {
    case fighter(String)
    case tournament(Int)
}

private enum DBZDeepLinkParseError: LocalizedError {
    case invalidScheme
    case missingRoute
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .invalidScheme:
            return "El esquema debe ser dragonball://"
        case .missingRoute:
            return "No se encontro una ruta valida."
        case .invalidPayload:
            return "La ruta existe pero los parametros no son validos."
        }
    }
}

@MainActor
private final class DBZDeepLinkNavigationViewModel: ObservableObject {
    @Published var rawURL = "dragonball://fighter/goku"
    @Published private(set) var logs: [String] = []
    @Published var path: [DBZDeepLinkDestination] = []

    func openURL() {
        do {
            let destination = try parse(urlString: rawURL)
            path = [destination]
            logs.insert("Deep link valido: \(rawURL)", at: 0)
        } catch {
            logs.insert("Error: \(error.localizedDescription)", at: 0)
        }
    }

    func loadExample(_ url: String) {
        rawURL = url
    }

    private func parse(urlString: String) throws -> DBZDeepLinkDestination {
        guard let url = URL(string: urlString), url.scheme == "dragonball" else {
            throw DBZDeepLinkParseError.invalidScheme
        }

        let host = url.host() ?? ""
        let components = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "fighter":
            guard let fighter = components.first, !fighter.isEmpty else {
                throw DBZDeepLinkParseError.invalidPayload
            }
            return .fighter(fighter.capitalized)
        case "tournament":
            guard let roundString = components.first, let round = Int(roundString) else {
                throw DBZDeepLinkParseError.invalidPayload
            }
            return .tournament(round)
        default:
            throw DBZDeepLinkParseError.missingRoute
        }
    }
}

struct DBZDeepLinkNavigationView: View {
    @StateObject private var viewModel = DBZDeepLinkNavigationViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pantalla 23: Deep Link + Navigation Lab")
                        .font(.title3.bold())

                    Text("Practica parseo de URLs, validacion de rutas y navegacion programatica desde un deep link.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("dragonball://fighter/goku", text: $viewModel.rawURL)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Abrir deep link") {
                        viewModel.openURL()
                    }
                    .buttonStyle(.borderedProminent)

                    HStack {
                        Button("Ejemplo fighter") {
                            viewModel.loadExample("dragonball://fighter/vegeta")
                        }
                        .buttonStyle(.bordered)

                        Button("Ejemplo torneo") {
                            viewModel.loadExample("dragonball://tournament/7")
                        }
                        .buttonStyle(.bordered)
                    }

                    Button("Ejemplo invalido") {
                        viewModel.loadExample("dragonball://planet/namek")
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
            .navigationTitle("DBZ Deep Links")
            .navigationDestination(for: DBZDeepLinkDestination.self) { destination in
                switch destination {
                case .fighter(let name):
                    DBZDeepLinkFighterDetailView(name: name)
                case .tournament(let round):
                    DBZDeepLinkTournamentView(round: round)
                }
            }
        }
    }
}

private struct DBZDeepLinkFighterDetailView: View {
    let name: String

    var body: some View {
        VStack(spacing: 16) {
            Text("Detalle de fighter")
                .font(.title2.bold())
            Text(name)
                .font(.largeTitle.weight(.black))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.orange.opacity(0.12))
    }
}

private struct DBZDeepLinkTournamentView: View {
    let round: Int

    var body: some View {
        VStack(spacing: 16) {
            Text("Bracket del torneo")
                .font(.title2.bold())
            Text("Ronda \(round)")
                .font(.largeTitle.weight(.black))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.blue.opacity(0.12))
    }
}
