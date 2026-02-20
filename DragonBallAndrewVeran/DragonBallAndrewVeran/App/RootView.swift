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
            }
            .navigationTitle("Menu Principal")
        }
    }
}
