import SwiftUI

private struct DBZOfflineFighter: Identifiable, Equatable {
    let id: UUID
    let name: String
    let powerLevel: Int
    let source: String
}

private protocol DBZOfflineCacheStore {
    func load() -> [DBZOfflineFighter]
    func save(_ fighters: [DBZOfflineFighter])
}

private protocol DBZOfflineRemoteDataSource {
    func fetchLatest() async throws -> [DBZOfflineFighter]
}

private final class DBZInMemoryOfflineCacheStore: DBZOfflineCacheStore {
    private var fighters: [DBZOfflineFighter] = [
        DBZOfflineFighter(id: UUID(), name: "Goku", powerLevel: 9000, source: "cache"),
        DBZOfflineFighter(id: UUID(), name: "Vegeta", powerLevel: 8800, source: "cache")
    ]

    func load() -> [DBZOfflineFighter] {
        fighters
    }

    func save(_ fighters: [DBZOfflineFighter]) {
        self.fighters = fighters
    }
}

private struct DBZMockOfflineRemoteDataSource: DBZOfflineRemoteDataSource {
    func fetchLatest() async throws -> [DBZOfflineFighter] {
        try await Task.sleep(for: .milliseconds(900))
        return [
            DBZOfflineFighter(id: UUID(), name: "Goku", powerLevel: 9300, source: "remote"),
            DBZOfflineFighter(id: UUID(), name: "Vegeta", powerLevel: 9100, source: "remote"),
            DBZOfflineFighter(id: UUID(), name: "Broly", powerLevel: 12000, source: "remote")
        ]
    }
}

private protocol DBZOfflineSyncRepository {
    func loadCached() -> [DBZOfflineFighter]
    func refresh() async throws -> [DBZOfflineFighter]
}

private struct DBZOfflineSyncRepositoryImpl: DBZOfflineSyncRepository {
    let cache: any DBZOfflineCacheStore
    let remote: any DBZOfflineRemoteDataSource

    func loadCached() -> [DBZOfflineFighter] {
        cache.load()
    }

    func refresh() async throws -> [DBZOfflineFighter] {
        let latest = try await remote.fetchLatest()
        cache.save(latest)
        return latest
    }
}

private protocol DBZLoadOfflineSyncUseCase {
    func loadCached() -> [DBZOfflineFighter]
    func refresh() async throws -> [DBZOfflineFighter]
}

private struct DBZLoadOfflineSyncUseCaseImpl: DBZLoadOfflineSyncUseCase {
    let repository: any DBZOfflineSyncRepository

    func loadCached() -> [DBZOfflineFighter] {
        repository.loadCached()
    }

    func refresh() async throws -> [DBZOfflineFighter] {
        try await repository.refresh()
    }
}

@MainActor
private final class DBZOfflineSyncViewModel: ObservableObject {
    @Published private(set) var fighters: [DBZOfflineFighter] = []
    @Published private(set) var status = "Idle"
    @Published private(set) var lastStrategy = "No data yet"

    private let useCase: any DBZLoadOfflineSyncUseCase

    init(useCase: any DBZLoadOfflineSyncUseCase) {
        self.useCase = useCase
    }

    func loadOfflineFirst() {
        fighters = useCase.loadCached()
        status = "Mostrando cache local inmediata"
        lastStrategy = "offline-first: cache first"
    }

    func staleWhileRevalidate() {
        fighters = useCase.loadCached()
        status = "Cache mostrada. Revalidando remoto..."
        lastStrategy = "stale-while-revalidate"

        Task {
            do {
                let latest = try await useCase.refresh()
                fighters = latest
                status = "Sincronizacion remota completada"
            } catch {
                status = "Error remoto. Se mantiene cache: \(error.localizedDescription)"
            }
        }
    }
}

struct DBZOfflineSyncView: View {
    @StateObject private var viewModel: DBZOfflineSyncViewModel

    init() {
        let cache = DBZInMemoryOfflineCacheStore()
        let remote = DBZMockOfflineRemoteDataSource()
        let repository = DBZOfflineSyncRepositoryImpl(cache: cache, remote: remote)
        let useCase = DBZLoadOfflineSyncUseCaseImpl(repository: repository)
        _viewModel = StateObject(wrappedValue: DBZOfflineSyncViewModel(useCase: useCase))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 27: Offline First + Sync")
                    .font(.title3.bold())

                Text("Compara cargar datos desde cache local contra mostrar cache y luego refrescar remoto sin bloquear la UI.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Cargar cache") {
                        viewModel.loadOfflineFirst()
                    }
                    .buttonStyle(.bordered)

                    Button("Stale-while-revalidate") {
                        viewModel.staleWhileRevalidate()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text("Estado: \(viewModel.status)")
                    .font(.callout.monospaced())

                Text("Estrategia: \(viewModel.lastStrategy)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(viewModel.fighters) { fighter in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(fighter.name)
                            .font(.headline)
                        Text("Power Level: \(fighter.powerLevel)")
                        Text("Source: \(fighter.source)")
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
        .navigationTitle("DBZ Offline Sync")
    }
}
