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

/// Menu principal de la app de estudio.
///
/// Senior interview note:
/// - Este RootView no conoce detalles de networking ni de dominio.
/// - Mantener el root lo mas simple posible reduce acoplamiento y facilita escalar rutas.
struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                // Pantalla 1: POST mock con Combine.
                NavigationLink("Pantalla 1 - Viaje del dato") {
                    DBZCheckView()
                }

                // Pantalla 2: API real + async/await + Task + MainActor.
                NavigationLink("Pantalla 2 - API real async/await") {
                    DBZAsyncView()
                }

                // Pantalla 3: laboratorio de estado en SwiftUI.
                NavigationLink("Pantalla 3 - State Lab") {
                    StateLabView()
                }

                // Pantalla 4: ciclo de vida UIKit con tema DBZ.
                NavigationLink("Pantalla 4 - UIKit Lifecycle") {
                    DBZLifecycleView()
                }

                // Pantalla 5: concurrencia avanzada con tema DBZ.
                NavigationLink("Pantalla 5 - Concurrency Lab") {
                    DBZConcurrencyView()
                }

                // Pantalla 6: almacenamiento (UserDefaults + Keychain + Singleton).
                NavigationLink("Pantalla 6 - Storage Lab") {
                    DBZStorageView()
                }

                // Pantalla 7: persistencia estructurada (Core Data + SwiftData).
                NavigationLink("Pantalla 7 - Persistence Lab") {
                    DBZPersistenceView()
                }

                // Pantalla 8: SOLID + VIPER.
                NavigationLink("Pantalla 8 - SOLID + VIPER") {
                    DBZArchitectureView()
                }

                // Pantalla 9: UI Flow (containers + lifecycle moderno).
                NavigationLink("Pantalla 9 - UI Flow Lab") {
                    DBZUIFlowView()
                }

                // Pantalla 10: calidad (testing doubles, retry/backoff, observabilidad).
                NavigationLink("Pantalla 10 - Quality Lab") {
                    DBZQualityView()
                }

                // Pantalla 11: seguridad y release strategy.
                NavigationLink("Pantalla 11 - Security + Release") {
                    DBZSecurityReleaseView()
                }

                // Pantalla 12: CI/CD mindset y decision de release.
                NavigationLink("Pantalla 12 - Delivery Lab") {
                    DBZDeliveryView()
                }

                // Pantalla 13: lista UIKit programatica + lifecycle + delegate flow.
                NavigationLink("Pantalla 13 - UIKit List Lifecycle") {
                    DBZUIKitListLifecycleView()
                }

                // Pantallas 14-22: laboratorios de Instruments.
                NavigationLink("Pantalla 14 - Instruments Leaks") {
                    DBZInstrumentsLeaksView()
                }

                NavigationLink("Pantalla 15 - Instruments Allocations") {
                    DBZInstrumentsAllocationsView()
                }

                NavigationLink("Pantalla 16 - Instruments VM Tracker") {
                    DBZInstrumentsVMTrackerView()
                }

                NavigationLink("Pantalla 17 - Instruments Time Profiler") {
                    DBZInstrumentsTimeProfilerView()
                }

                NavigationLink("Pantalla 18 - Instruments Core Animation") {
                    DBZInstrumentsCoreAnimationView()
                }

                NavigationLink("Pantalla 19 - Instruments Network") {
                    DBZInstrumentsNetworkView()
                }

                NavigationLink("Pantalla 20 - Instruments File Activity") {
                    DBZInstrumentsFileActivityView()
                }

                NavigationLink("Pantalla 21 - Instruments Energy Log") {
                    DBZInstrumentsEnergyView()
                }

                NavigationLink("Pantalla 22 - Instruments Concurrency") {
                    DBZInstrumentsConcurrencyView()
                }

                // Pantallas 23-25: temas senior siguientes.
                NavigationLink("Pantalla 23 - Deep Link + Navigation") {
                    DBZDeepLinkNavigationView()
                }

                NavigationLink("Pantalla 24 - DI Container + Module Assembly") {
                    DBZDIContainerView()
                }

                NavigationLink("Pantalla 25 - Testing Lab Real") {
                    DBZTestingLabView()
                }

                NavigationLink("Pantalla 26 - GraphQL + Apollo Lab") {
                    DBZGraphQLApolloView()
                }

                NavigationLink("Pantalla 27 - Offline First + Sync") {
                    DBZOfflineSyncView()
                }

                NavigationLink("Pantalla 28 - Background Tasks Lab") {
                    DBZBackgroundTasksView()
                }
            }
            .navigationTitle("Menu Principal")
        }
    }
}
