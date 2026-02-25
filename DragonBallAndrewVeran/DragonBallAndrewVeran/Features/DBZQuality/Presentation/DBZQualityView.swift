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
#if canImport(RxSwift)
import RxSwift
#endif

// MARK: - Domain Contract

protocol PowerLevelService {
    /// FUNC-GUIDE: fetchPowerLevel
    /// - Qué hace: contrato base para obtener power level de un guerrero.
    /// - Entrada: `warrior`.
    /// - Salida: un `Int` o error.
    /// FUNC-GUIDE: fetchPowerLevel
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func fetchPowerLevel(for warrior: String) async throws -> Int
}

// MARK: - Test Doubles

/// Stub: siempre devuelve un valor fijo (éxito controlado).
struct StubPowerLevelService: PowerLevelService {
    let fixedValue: Int

    /// FUNC-GUIDE: fetchPowerLevel
    /// - Qué hace: responde un valor constante para pruebas deterministas.
    /// - Uso: tests rápidos donde no quieres fallos ni latencia real.
    /// FUNC-GUIDE: fetchPowerLevel
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func fetchPowerLevel(for warrior: String) async throws -> Int {
        fixedValue
    }
}

/// Fake/Flaky: falla N veces y luego responde bien (útil para probar retry/backoff).
final class FlakyPowerLevelService: PowerLevelService {
    private var remainingFailures: Int
    private let successValue: Int

    /// FUNC-GUIDE: init
    /// - Qué hace: configura cuántas veces fallará antes de devolver éxito.
    /// - Uso: reproducir escenarios de retry/backoff.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(failuresBeforeSuccess: Int, successValue: Int = 9000) {
        self.remainingFailures = failuresBeforeSuccess
        self.successValue = successValue
    }

    /// FUNC-GUIDE: fetchPowerLevel
    /// - Qué hace: simula latencia y fallos temporales controlados.
    /// - Salida: error durante los primeros intentos, luego éxito.
    /// FUNC-GUIDE: fetchPowerLevel
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func fetchPowerLevel(for warrior: String) async throws -> Int {
        try await Task.sleep(nanoseconds: 180_000_000)

        if remainingFailures > 0 {
            remainingFailures -= 1
            throw NSError(domain: "FlakyService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Scouter timeout simulado"])
        }

        return successValue
    }
}

/// Spy logger para observabilidad (captura eventos y también imprime).
final class SpyLogger {
    private(set) var events: [String] = []

    /// FUNC-GUIDE: log
    /// - Qué hace: guarda y muestra un evento para observabilidad.
    /// - Uso: auditar intentos, errores y tiempos en la demo.
    /// FUNC-GUIDE: log
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func log(_ message: String) {
        events.append(message)
        print("[QUALITY][LOG] \(message)")
    }

    /// FUNC-GUIDE: clear
    /// - Qué hace: limpia eventos anteriores para iniciar una corrida limpia.
    /// FUNC-GUIDE: clear
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func clear() {
        events.removeAll()
    }
}

@MainActor
final class DBZQualityViewModel: ObservableObject {
    enum ServiceMode: String, CaseIterable, Identifiable {
        case stub = "Stub (siempre éxito)"
        case flaky = "Flaky (retry)"
#if canImport(RxSwift)
        case rxswift = "RxSwift (observable + retry)"
#endif

        var id: String { rawValue }
    }

    @Published var warriorInput: String = "Goku"
    @Published var mode: ServiceMode = .flaky

    @Published private(set) var stateText: String = "Idle"
    @Published private(set) var resultText: String = "Sin resultado"
    @Published private(set) var durationText: String = "-"
    @Published private(set) var logsText: String = ""

    private let logger = SpyLogger()
#if canImport(RxSwift)
    /// RxSwift usa DisposeBag para gestionar el ciclo de vida de subscripciones.
    /// Diferencia con Combine:
    /// - Combine -> Set<AnyCancellable>
    /// - RxSwift -> DisposeBag
    private var disposeBag = DisposeBag()
#endif

    /// FUNC-GUIDE: runScan
    /// - Qué hace: punto de entrada de la pantalla.
    /// - Decisión: si el modo es RxSwift usa flujo Rx, en otro caso async/await.
    /// FUNC-GUIDE: runScan
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func runScan() {
#if canImport(RxSwift)
        if mode == .rxswift {
            runScanWithRxSwift()
            return
        }
#endif

        Task {
            await executeRun()
        }
    }

    /// Construye el servicio según el modo elegido en UI.
    /// - Stub: éxito fijo.
    /// - Flaky/Rx: fallos iniciales para observar retries.
    /// FUNC-GUIDE: makeService
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func makeService() -> PowerLevelService {
        switch mode {
        case .stub:
            return StubPowerLevelService(fixedValue: 8000)
        case .flaky:
            return FlakyPowerLevelService(failuresBeforeSuccess: 2, successValue: 9200)
#if canImport(RxSwift)
        case .rxswift:
            // Para la demo Rx usamos servicio flaky, para ver retry en acción.
            return FlakyPowerLevelService(failuresBeforeSuccess: 2, successValue: 9300)
#endif
        }
    }

    /// Flujo principal con async/await:
    /// 1) valida input
    /// 2) mide tiempo
    /// 3) ejecuta retry/backoff
    /// 4) publica resultado y logs
    /// FUNC-GUIDE: executeRun
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func executeRun() async {
        let warrior = warriorInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !warrior.isEmpty else {
            stateText = "Error"
            resultText = "Escribe un guerrero"
            return
        }

        stateText = "Running"
        resultText = "Consultando..."
        durationText = "-"
        logger.clear()

        let service = makeService()
        let clock = ContinuousClock()
        let start = clock.now

        do {
            let power = try await fetchWithRetry(service: service, warrior: warrior, retries: 3)
            let elapsed = start.duration(to: clock.now)
            let ms = elapsed.components.seconds * 1000 + elapsed.components.attoseconds / 1_000_000_000_000_000

            stateText = "Success"
            resultText = "\(warrior) power level = \(power)"
            durationText = "Duración aprox: \(ms) ms"
            logger.log("SUCCESS warrior=\(warrior) power=\(power) durationMs=\(ms)")
        } catch {
            stateText = "Failure"
            resultText = "Error final: \(error.localizedDescription)"
            logger.log("FAILURE warrior=\(warrior) error=\(error.localizedDescription)")
        }

        logsText = logger.events.joined(separator: "\n")
    }

#if canImport(RxSwift)
    /// Demostración RxSwift.
    ///
    /// Diferencias clave con Combine:
    /// - Combine suele arrancar con publishers nativos (URLSession publisher, etc).
    /// - RxSwift arranca con Observable/Single y opera con operadores Rx.
    /// - En Rx usamos DisposeBag para cancelar automáticamente al liberar.
    /// FUNC-GUIDE: runScanWithRxSwift
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func runScanWithRxSwift() {
        let warrior = warriorInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !warrior.isEmpty else {
            stateText = "Error"
            resultText = "Escribe un guerrero"
            return
        }

        stateText = "Running (RxSwift)"
        resultText = "Consultando con Rx..."
        durationText = "-"
        logger.clear()

        // Reiniciamos bag para limpiar subscripciones anteriores de esta demo.
        disposeBag = DisposeBag()

        let service = makeService()
        let clock = ContinuousClock()
        let start = clock.now

        // Single representa 1 éxito o 1 error, ideal para requests de red.
        let single = makeRxSingle(service: service, warrior: warrior)
            .do(onSubscribe: { [weak self] in
                self?.logger.log("rx subscribe warrior=\(warrior)")
            }, onSuccess: { [weak self] value in
                self?.logger.log("rx success value=\(value)")
            }, onFailure: { [weak self] error in
                self?.logger.log("rx failure error=\(error.localizedDescription)")
            })
            .retry(2) // Rx retry simple: reintenta ante error.

        single
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] power in
                guard let self else { return }
                let elapsed = start.duration(to: clock.now)
                let ms = elapsed.components.seconds * 1000 + elapsed.components.attoseconds / 1_000_000_000_000_000

                self.stateText = "Success (RxSwift)"
                self.resultText = "\(warrior) power level = \(power)"
                self.durationText = "Duración aprox: \(ms) ms"
                self.logsText = self.logger.events.joined(separator: "\n")
            }, onFailure: { [weak self] error in
                guard let self else { return }
                self.stateText = "Failure (RxSwift)"
                self.resultText = "Error final: \(error.localizedDescription)"
                self.logsText = self.logger.events.joined(separator: "\n")
            })
            .disposed(by: disposeBag)
    }

    /// Puente async/await -> RxSwift Single para reutilizar el mismo servicio.
    /// FUNC-GUIDE: makeRxSingle
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func makeRxSingle(service: PowerLevelService, warrior: String) -> Single<Int> {
        Single<Int>.create { single in
            let task = Task {
                do {
                    let value = try await service.fetchPowerLevel(for: warrior)
                    single(.success(value))
                } catch {
                    single(.failure(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
#endif

    /// Retry con backoff exponencial sencillo: 200ms, 400ms, 800ms...
    /// Ejecuta la llamada y reintenta ante error.
    /// - `retries = 3` permite hasta 4 intentos totales (1 inicial + 3 retries).
    /// - Backoff exponencial: 200ms, 400ms, 800ms...
    /// FUNC-GUIDE: fetchWithRetry
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private func fetchWithRetry(service: PowerLevelService, warrior: String, retries: Int) async throws -> Int {
        var attempt = 0
        while true {
            do {
                attempt += 1
                logger.log("attempt=\(attempt) warrior=\(warrior)")
                return try await service.fetchPowerLevel(for: warrior)
            } catch {
                logger.log("attempt=\(attempt) failed error=\(error.localizedDescription)")

                if attempt > retries {
                    throw error
                }

                let backoffNs = UInt64(200_000_000 * Int(pow(2.0, Double(attempt - 1))))
                logger.log("backoff=\(backoffNs)ns")
                try await Task.sleep(nanoseconds: backoffNs)
            }
        }
    }
}

struct DBZQualityView: View {
    @StateObject private var viewModel = DBZQualityViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pantalla 10: Quality Lab DBZ")
                    .font(.title2.bold())

                GroupBox("Qué aprendes aquí") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1) Test doubles: Stub, Fake/Flaky, Spy")
                        Text("2) Error handling con retry + backoff")
                        Text("3) Observabilidad: logs estructurados")
                        Text("4) Métrica simple de rendimiento (duración)")
                        Text("5) Diferencia Combine vs RxSwift (si Rx está instalado)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                GroupBox("Combine vs RxSwift (resumen rápido)") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Combine: Publisher + AnyCancellable + operadores Apple.")
                        Text("RxSwift: Observable/Single + DisposeBag + operadores Rx.")
                        Text("Ambos permiten map/retry/filter, pero cambia el ecosistema y el tipado.")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Picker("Modo", selection: $viewModel.mode) {
                    ForEach(DBZQualityViewModel.ServiceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Guerrero (ej: Goku)", text: $viewModel.warriorInput)
                    .textFieldStyle(.roundedBorder)

                Button("Run Quality Scan") {
                    viewModel.runScan()
                }
                .buttonStyle(.borderedProminent)

                Text("Estado: \(viewModel.stateText)")
                    .font(.headline)
                Text(viewModel.resultText)
                Text(viewModel.durationText)
                    .foregroundStyle(.secondary)

                GroupBox("Logs (SpyLogger)") {
                    Text(viewModel.logsText.isEmpty ? "Sin logs" : viewModel.logsText)
                        .font(.caption.monospaced())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle("DBZ Quality")
    }
}
