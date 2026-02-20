import SwiftUI

/// Entry point de la aplicacion.
///
/// Senior interview note:
/// - El App struct define el ciclo de vida en SwiftUI moderno.
/// - Evita poner logica de negocio aqui; delegala al arbol de vistas/modulos.
@main
struct DragonBallAndrewVeranApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
