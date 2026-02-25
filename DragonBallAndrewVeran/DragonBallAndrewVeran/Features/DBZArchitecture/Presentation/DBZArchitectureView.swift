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

// MARK: - VIPER Entity

struct DBZFighterRank: Identifiable {
    let id = UUID()
    let name: String
    let tier: String
}

// MARK: - VIPER Contracts

protocol DBZRankViewProtocol: AnyObject {
    /// FUNC-GUIDE: showLoading
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showLoading
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showLoading(_ loading: Bool)
    /// FUNC-GUIDE: showResult
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showResult
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showResult(_ fighter: DBZFighterRank)
    /// FUNC-GUIDE: showError
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showError
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showError(_ message: String)
    /// FUNC-GUIDE: showRouteMessage
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showRouteMessage
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showRouteMessage(_ message: String)
}

protocol DBZRankPresenterProtocol {
    /// FUNC-GUIDE: onSearchTapped
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: onSearchTapped
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func onSearchTapped(name: String)
    /// FUNC-GUIDE: onOpenDetailTapped
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: onOpenDetailTapped
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func onOpenDetailTapped()
}

protocol DBZRankInteractorProtocol {
    /// FUNC-GUIDE: findFighter
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: findFighter
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func findFighter(name: String) -> DBZFighterRank?
}

protocol DBZRankRouterProtocol {
    /// FUNC-GUIDE: routeToDetail
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: routeToDetail
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func routeToDetail(for fighter: DBZFighterRank) -> String
}

// MARK: - VIPER Interactor

/// SRP: solo resuelve reglas de negocio de búsqueda.
final class DBZRankInteractor: DBZRankInteractorProtocol {
    private let fighters: [DBZFighterRank] = [
        DBZFighterRank(name: "Goku", tier: "S"),
        DBZFighterRank(name: "Vegeta", tier: "A"),
        DBZFighterRank(name: "Broly", tier: "S+")
    ]

    /// FUNC-GUIDE: findFighter
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: findFighter
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func findFighter(name: String) -> DBZFighterRank? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return fighters.first { $0.name.lowercased() == normalized }
    }
}

// MARK: - VIPER Router

/// SRP: solo define navegación/mensaje de ruta.
final class DBZRankRouter: DBZRankRouterProtocol {
    /// FUNC-GUIDE: routeToDetail
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: routeToDetail
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func routeToDetail(for fighter: DBZFighterRank) -> String {
        "Router: navegar a detalle de \(fighter.name) (Tier \(fighter.tier))"
    }
}

// MARK: - VIPER Presenter

/// DIP: depende de protocolos (Interactor/Router/View), no de concretos.
final class DBZRankPresenter: DBZRankPresenterProtocol {
    private let interactor: DBZRankInteractorProtocol
    private let router: DBZRankRouterProtocol
    private weak var view: DBZRankViewProtocol?
    private var selectedFighter: DBZFighterRank?

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(interactor: DBZRankInteractorProtocol, router: DBZRankRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    /// FUNC-GUIDE: attachView
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: attachView
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func attachView(_ view: DBZRankViewProtocol) {
        self.view = view
    }

    /// FUNC-GUIDE: onSearchTapped
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: onSearchTapped
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func onSearchTapped(name: String) {
        view?.showLoading(true)

        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            selectedFighter = nil
            view?.showLoading(false)
            view?.showError("Escribe un guerrero (ej: Goku)")
            return
        }

        if let fighter = interactor.findFighter(name: name) {
            selectedFighter = fighter
            view?.showResult(fighter)
        } else {
            selectedFighter = nil
            view?.showError("No encontrado en ranking")
        }

        view?.showLoading(false)
    }

    /// FUNC-GUIDE: onOpenDetailTapped
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: onOpenDetailTapped
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func onOpenDetailTapped() {
        guard let selectedFighter else {
            view?.showError("Primero busca un guerrero")
            return
        }

        let routeMessage = router.routeToDetail(for: selectedFighter)
        view?.showRouteMessage(routeMessage)
    }
}

// MARK: - SwiftUI Adapter for VIPER View

@MainActor
final class DBZRankViewAdapter: ObservableObject, DBZRankViewProtocol {
    @Published var inputName: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var resultText: String = "Sin búsqueda"
    @Published private(set) var routeText: String = "Sin navegación"

    private let presenter: DBZRankPresenter

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init() {
        let interactor = DBZRankInteractor()
        let router = DBZRankRouter()
        presenter = DBZRankPresenter(interactor: interactor, router: router)
        presenter.attachView(self)
    }

    /// FUNC-GUIDE: search
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: search
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func search() {
        print("[VIPER][VIEW] Tap buscar name=\(inputName)")
        presenter.onSearchTapped(name: inputName)
    }

    /// FUNC-GUIDE: openDetail
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: openDetail
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func openDetail() {
        print("[VIPER][VIEW] Tap abrir detalle")
        presenter.onOpenDetailTapped()
    }

    /// FUNC-GUIDE: showLoading
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showLoading
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showLoading(_ loading: Bool) {
        isLoading = loading
        print("[VIPER][VIEW] loading=\(loading)")
    }

    /// FUNC-GUIDE: showResult
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showResult
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showResult(_ fighter: DBZFighterRank) {
        resultText = "\(fighter.name) -> Tier \(fighter.tier)"
        print("[VIPER][VIEW] result=\(resultText)")
    }

    /// FUNC-GUIDE: showError
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showError
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showError(_ message: String) {
        resultText = "Error: \(message)"
        print("[VIPER][VIEW] error=\(message)")
    }

    /// FUNC-GUIDE: showRouteMessage
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: showRouteMessage
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func showRouteMessage(_ message: String) {
        routeText = message
        print("[VIPER][VIEW] route=\(message)")
    }
}

// MARK: - Screen 8

struct DBZArchitectureView: View {
    @StateObject private var adapter = DBZRankViewAdapter()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 8: SOLID + VIPER DBZ")
                    .font(.title2.bold())

                GroupBox("Qué aprendes aquí") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) VIPER real: View, Interactor, Presenter, Entity, Router")
                        Text("2) SRP: cada clase tiene una responsabilidad")
                        Text("3) DIP: Presenter depende de protocolos")
                        Text("4) Cómo separar UI, negocio y navegación")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Mini demo VIPER") {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Buscar guerrero (Goku/Vegeta/Broly)", text: $adapter.inputName)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("Buscar") { adapter.search() }
                            Button("Abrir detalle") { adapter.openDetail() }
                        }
                        .buttonStyle(.borderedProminent)

                        if adapter.isLoading {
                            ProgressView("Buscando...")
                        }

                        Text("Resultado: \(adapter.resultText)")
                        Text("Ruta: \(adapter.routeText)")
                            .foregroundStyle(.secondary)
                    }
                }

                GroupBox("SOLID aplicado (rápido)") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SRP: Interactor busca, Router navega, Presenter coordina")
                        Text("DIP: Presenter usa protocolos en vez de tipos concretos")
                        Text("OCP: puedes añadir otro Interactor sin cambiar Presenter")
                        Text("ISP: contratos pequeños por responsabilidad")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("DBZ VIPER")
    }
}
