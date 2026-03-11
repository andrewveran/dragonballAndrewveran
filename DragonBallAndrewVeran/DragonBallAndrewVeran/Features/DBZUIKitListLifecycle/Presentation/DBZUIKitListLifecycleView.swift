// LEARNING-CODE-GUIDE:
// Este archivo forma parte de una app de estudio progresiva iOS (tema Dragon Ball).
//
// Como leer este archivo (guia rapida):
// 1) Objetivo del archivo: identificar como una lista UIKit se construye y refresca.
// 2) Entrada principal: estrategia de carga (eager o paginada) y eventos lifecycle.
// 3) Transformacion: generar dataset + aplicar paginacion + render en UITableView.
// 4) Salida: celdas visibles + logs de costo/tiempo.
// 5) Logs: sigue prefijos [UIKIT][LIST-LIFECYCLE] para ver el flujo.
import SwiftUI
import UIKit

struct DBZUIKitListLifecycleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 13: UIKit List Lifecycle")
                    .font(.title2.bold())

                GroupBox("Donde conviene esta demo") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Pantalla individual: mejor para estudiar lifecycle + delegates sin ruido.")
                        Text("Aqui se ve claramente: construccion de datos, refresco y costo por estrategia.")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Mapa rapido de responsabilidades") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("viewDidLoad: crear UI + conectar delegates + primera carga.")
                        Text("viewWillAppear: refresco liviano si cambia contexto.")
                        Text("UIRefreshControl: refresco manual por pull-to-refresh.")
                        Text("UITableViewDataSource/Delegate/Prefetch: render, scroll y carga incremental.")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                DBZUIKitListLifecycleContainer()
                    .frame(height: 560)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray.opacity(0.25), lineWidth: 1)
                    )
            }
            .padding()
        }
        .navigationTitle("DBZ UIKit List")
    }
}

private struct DBZUIKitListLifecycleContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DBZUIKitListLifecycleViewController {
        DBZUIKitListLifecycleViewController()
    }

    func updateUIViewController(_ uiViewController: DBZUIKitListLifecycleViewController, context: Context) {
        // No-op: la demo controla su propio ciclo interno.
    }
}

private struct DBZFighterItem: Hashable {
    let id: Int
    let name: String
    let powerLevel: Int
}

private enum DBZLoadStrategy: Int {
    case eager
    case paged

    var title: String {
        switch self {
        case .eager: return "Carga completa"
        case .paged: return "Carga paginada"
        }
    }
}

private final class DBZUIKitListLifecycleViewController: UIViewController {
    private let infoLabel = UILabel()
    private let lifecycleLabel = UILabel()
    private let strategyControl = UISegmentedControl(items: [
        DBZLoadStrategy.eager.title,
        DBZLoadStrategy.paged.title
    ])
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()

    private var allItems: [DBZFighterItem] = []
    private var visibleItems: [DBZFighterItem] = []
    private let pageSize = 120
    private var isLoadingMore = false
    private var buildCount = 0

    private var strategy: DBZLoadStrategy {
        DBZLoadStrategy(rawValue: strategyControl.selectedSegmentIndex) ?? .paged
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[UIKIT][LIST-LIFECYCLE] viewDidLoad")
        configureUI()
        configureTable()
        buildDataAndRender(origin: "viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[UIKIT][LIST-LIFECYCLE] viewWillAppear")
        lifecycleLabel.text = "viewWillAppear: usar para refresco liviano si cambia contexto"
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        [infoLabel, lifecycleLabel, strategyControl, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        infoLabel.numberOfLines = 0
        infoLabel.font = .preferredFont(forTextStyle: .footnote)
        infoLabel.textColor = .secondaryLabel
        infoLabel.text = "Construccion: pendiente"

        lifecycleLabel.numberOfLines = 0
        lifecycleLabel.font = .preferredFont(forTextStyle: .footnote)
        lifecycleLabel.textColor = .secondaryLabel
        lifecycleLabel.text = "Lifecycle: pendiente"

        strategyControl.selectedSegmentIndex = DBZLoadStrategy.paged.rawValue
        strategyControl.addTarget(self, action: #selector(strategyChanged), for: .valueChanged)

        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            lifecycleLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            lifecycleLabel.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            lifecycleLabel.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),

            strategyControl.topAnchor.constraint(equalTo: lifecycleLabel.bottomAnchor, constant: 12),
            strategyControl.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor),
            strategyControl.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: strategyControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self

        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    // Punto principal donde se construyen datos para la lista.
    // Costoso si generas/transformas dataset grande en main thread.
    private func buildDataAndRender(origin: String) {
        buildCount += 1
        let currentBuild = buildCount
        lifecycleLabel.text = "\(origin): construir datos y refrescar tabla"
        print("[UIKIT][LIST-LIFECYCLE] buildDataAndRender origin=\(origin), strategy=\(strategy.title)")

        let start = CFAbsoluteTimeGetCurrent()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let generated = Self.generateMassiveDataset(total: 5000)
            let elapsedMs = (CFAbsoluteTimeGetCurrent() - start) * 1000

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard currentBuild == self.buildCount else { return }
                self.allItems = generated

                if self.strategy == .eager {
                    self.visibleItems = generated
                } else {
                    self.visibleItems = Array(generated.prefix(self.pageSize))
                }

                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.infoLabel.text = """
                Datos construidos en \(origin).
                Estrategia: \(self.strategy.title).
                Dataset total: \(self.allItems.count).
                Render inicial: \(self.visibleItems.count).
                Costo aprox de construccion: \(Int(elapsedMs)) ms.
                """
            }
        }
    }

    @objc private func strategyChanged() {
        buildDataAndRender(origin: "strategyChanged")
    }

    @objc private func refreshPulled() {
        buildDataAndRender(origin: "pullToRefresh")
    }

    private func loadNextPageIfNeeded(trigger: String) {
        guard strategy == .paged else { return }
        guard !isLoadingMore else { return }
        guard visibleItems.count < allItems.count else { return }

        isLoadingMore = true
        print("[UIKIT][LIST-LIFECYCLE] loadNextPage trigger=\(trigger)")

        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self else { return }
            let nextEnd = min(self.visibleItems.count + self.pageSize, self.allItems.count)
            let nextSlice = Array(self.allItems.prefix(nextEnd))

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.visibleItems = nextSlice
                self.tableView.reloadData()
                self.isLoadingMore = false
                self.lifecycleLabel.text = "Delegate/Prefetch: cargada pagina hasta \(nextEnd) elementos"
            }
        }
    }

    private static func generateMassiveDataset(total: Int) -> [DBZFighterItem] {
        var items: [DBZFighterItem] = []
        items.reserveCapacity(total)

        for index in 1...total {
            let fighter = DBZFighterItem(
                id: index,
                name: "Guerrero #\(index)",
                powerLevel: 10_000 + (index * 13 % 90_000)
            )
            items.append(fighter)
        }
        return items
    }
}

extension DBZUIKitListLifecycleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleItems.count
    }

    // cellForRowAt: debe ser rapido; evita trabajo pesado aqui.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = visibleItems[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = "Power Level: \(item.powerLevel)"
        cell.contentConfiguration = content
        return cell
    }
}

extension DBZUIKitListLifecycleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= max(0, visibleItems.count - 20) {
            loadNextPageIfNeeded(trigger: "willDisplay")
        }
    }
}

extension DBZUIKitListLifecycleViewController: UITableViewDataSourcePrefetching {
    // Prefetch adelanta trabajo cuando se aproximan filas futuras.
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let threshold = visibleItems.count - 20
        let nearEnd = indexPaths.contains { $0.row >= threshold }
        if nearEnd {
            loadNextPageIfNeeded(trigger: "prefetchRowsAt")
        }
    }
}
