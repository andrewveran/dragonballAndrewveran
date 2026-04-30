# Terminos aplicados y opciones (mini guia)

## Que es esta aplicacion
Esta aplicacion es una app de estudio iOS tematizada en Dragon Ball. La idea no es solo "mostrar pantallas", sino usar el tema de Dragon Ball como contexto para practicar conceptos reales de desarrollo iOS con Swift, SwiftUI, UIKit, arquitectura por capas, concurrencia, persistencia, seguridad, calidad, release y performance.

El proyecto esta pensado como una guia progresiva. Cada pantalla existe para explicar una idea concreta y aislarla lo suficiente como para que puedas entenderla sin perderte en demasiada complejidad al mismo tiempo. Por eso vas a ver una mezcla intencional de:
- ejemplos pequenos y faciles de seguir;
- separacion por features;
- pantallas tipo laboratorio;
- comentarios dentro del codigo que te dicen que mirar primero;
- nombres de archivos y carpetas bastante directos.

Si en el futuro quisieras replicar esta misma idea con otro tema, por ejemplo Naruto, Marvel, Pokemon o una app de ecommerce, lo importante no es Dragon Ball en si, sino la estructura didactica:
- un menu raiz con modulos pequenos;
- una pantalla por concepto o grupo de conceptos;
- arquitectura consistente entre features;
- comentarios orientados a lectura y estudio;
- ejemplos que permitan ver el flujo del dato de punta a punta.

## Vision grande del proyecto
La app esta construida como un proyecto de aprendizaje progresivo. Eso significa que no todo busca ser "la implementacion mas enterprise posible", sino una implementacion lo bastante clara para que puedas:
- abrir un archivo y entender rapidamente que rol cumple;
- seguir el viaje del dato desde la UI hasta la capa de datos;
- comparar patrones antiguos y modernos de iOS;
- usar el proyecto como base para entrevistas, practica tecnica o demos educativas.

En terminos generales, el proyecto mezcla:
- `SwiftUI` para la mayoria de pantallas y flujo principal;
- `UIKit` en pantallas puntuales para estudiar lifecycle, tablas y bridges;
- `MVVM`, `VIPER`, `Clean Architecture` y `DIP` como estilos de organizacion;
- `Combine`, `async/await`, `Task`, `TaskGroup`, `MainActor` y actores para concurrencia;
- `UserDefaults`, `Keychain`, `Core Data`, `SwiftData` y labs de performance para ampliar el rango de estudio.

## Como leer el proyecto
La forma correcta de leer esta app no es archivo por archivo al azar. Lo mejor es leerla en capas y en flujo.

Orden sugerido:
1. Empieza por el entry point de la aplicacion para entender donde nace todo.
2. Revisa el menu principal para ver como estan organizadas las pantallas.
3. Elige una sola pantalla y sigue ese modulo completo.
4. Dentro de esa pantalla, recorre `Presentation -> Domain -> Data`.
5. Cuando termines una pantalla, vuelve al menu y pasa a la siguiente.

Regla practica:
- si quieres entender navegacion y composicion, mira `App` y `RootView`;
- si quieres entender interaccion UI, mira `Presentation`;
- si quieres entender reglas de negocio, mira `Domain`;
- si quieres entender APIs, persistencia o detalles concretos, mira `Data`.

## Convenciones de comentarios dentro del codigo
Este proyecto tiene comentarios pensados para estudio. No son comentarios decorativos. La idea es que, al abrir un archivo, tengas una lectura guiada para entender su funcion dentro del sistema.

### `LEARNING-CODE-GUIDE:`
Este bloque aparece como encabezado en archivos importantes. Su objetivo es avisarte que ese archivo forma parte de una app de aprendizaje y que debe leerse como una pieza de una secuencia didactica, no solo como codigo aislado.

Que te comunica:
- el contexto general del archivo dentro del proyecto;
- que conviene leer ese archivo siguiendo un flujo;
- que el archivo tiene valor educativo, no solo funcional.

Si replicas este modelo en otra app, este comentario te sirve como "contrato pedagogico": cualquier archivo importante le dice al lector como abordarlo.

### `Como leer este archivo (guia rapida)`
Este bloque explica que mirar primero cuando abres un archivo. En este proyecto normalmente te orienta con preguntas como:
- cual es el objetivo del archivo;
- cual es su entrada principal;
- que transformacion hace;
- cual es su salida;
- que logs o pistas ayudan a seguir el flujo.

Este tipo de comentario es especialmente util cuando compartes el proyecto con alguien que aun no domina la base de codigo. En lugar de obligarlo a inferir todo desde cero, le das un mapa mental inicial.

Si quieres replicarlo, la recomendacion es mantener siempre la misma estructura para que todos los archivos "ensenen" de forma consistente.

### `Consejo de estudio`
Este bloque existe para bajar la ansiedad de lectura y darte una estrategia concreta. En esta app suele insistir en algo clave: seguir el flujo del dato.

La logica es:
- no intentes entender todo al mismo tiempo;
- toma un caso simple, por ejemplo `Goku`;
- sigue ese caso desde la UI hasta la respuesta;
- repite hasta que puedas explicar el modulo sin mirar el codigo.

Esto convierte la app en una herramienta de entrenamiento, no solo en una coleccion de features.

### `Senior interview note:`
Este comentario sirve para traducir una decision de codigo en lenguaje de entrevista tecnica o criterio senior. No solo dice "que hace" el codigo, sino "por que esta organizado asi" y que tradeoff de arquitectura o mantenimiento representa.

Normalmente este bloque apunta a cosas como:
- reducir acoplamiento;
- evitar logica de negocio en capas incorrectas;
- mantener responsabilidades claras;
- facilitar escalabilidad o testing;
- hacer que el root o la UI no conozcan detalles internos.

Si replicas la app en otro proyecto, este bloque es muy valioso porque documenta no solo la solucion, sino la intencion arquitectonica.

### `Entry point de la aplicacion`
Este concepto aparece documentado en el archivo principal `App`. Es el punto donde arranca la aplicacion.

En este proyecto el entry point esta en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/App/DragonBallAndrewVeranApp.swift`

Su responsabilidad es minima y correcta:
- levantar el ciclo de vida de SwiftUI moderno;
- crear el `WindowGroup`;
- montar `RootView()` como punto de entrada visual;
- evitar logica de negocio en esta capa.

Esta decision es importante porque te deja una base limpia. Si en el futuro replicas esta app, el `App` debe seguir siendo delgado. Su trabajo no es resolver negocio, networking, persistencia ni coordinacion compleja. Su trabajo es arrancar la aplicacion y delegar.

### `Menu principal`
Despues del entry point, el siguiente archivo clave es:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/App/RootView.swift`

`RootView` funciona como mapa del proyecto. Desde ahi puedes entender:
- cuantas pantallas tiene la app;
- en que orden fueron pensadas;
- que tema practica cada modulo;
- como crece la app sin que el entry point se vuelva complejo.

Este archivo tambien muestra una decision importante de replicacion futura: el menu raiz debe conocer rutas y nombres de pantallas, pero no la logica interna de cada modulo.

## Como replicar una app parecida en el futuro
Si mas adelante quieres construir otra app educativa con esta misma filosofia, la receta base seria:

1. Define un tema narrativo simple.
Dragon Ball aqui funciona como envoltura visual y conceptual. El tema ayuda a que los ejemplos no se sientan abstractos.

2. Organiza la app por features.
Cada modulo deberia vivir en su carpeta y, cuando tenga sentido, dividirse en `Presentation`, `Domain` y `Data`.

3. Decide un menu raiz progresivo.
La app debe invitar a estudiar por etapas. Un `RootView` con pantallas numeradas o claramente nombradas funciona muy bien.

4. Documenta el codigo para lectura, no solo para ejecucion.
Los comentarios guia de este proyecto son parte central del valor educativo.

5. Manten ejemplos pequenos pero reales.
No hace falta una mega app. Hace falta que cada pantalla sea clara y suficientemente realista para ensenar un concepto util.

6. Separa el "objetivo pedagogico" del "tema visual".
Mañana puedes cambiar Dragon Ball por otro universo, pero mantener la misma estructura de aprendizaje.

## Uso recomendado de este documento
Este markdown funciona como mapa de referencia del proyecto. La idea es que primero leas esta introduccion y luego uses las secciones por termino o por pantalla para aterrizar cada concepto en archivos reales.

La mejor forma de usarlo es:
- leer la descripcion global;
- abrir el `App` y el `RootView`;
- escoger una pantalla;
- venir aqui a buscar los terminos que practica;
- volver al codigo con ese mapa mental ya claro.

## 1) MVVM
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZCheck/Presentation/DBZCheckView.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZCheck/Presentation/DBZCheckViewModel.swift`

Mini opciones:
```swift
// View -> ViewModel action
Button("Enviar") { viewModel.submit() }

// ViewModel expone estado
@Published private(set) var state: DBZCheckViewState = .idle
```

## 2) Clean Architecture + Layer Boundaries
Se usa en:
- Presentation: `.../Presentation/...`
- Domain: `.../Domain/...`
- Data: `.../Data/...`

Mini opciones:
```swift
// Presentation llama UseCase
useCase.execute(answer: "Goku")

// Domain define contratos
protocol DBZCheckRepository { ... }

// Data implementa contratos
final class DBZCheckRepositoryImpl: DBZCheckRepository { ... }
```

## 3) Protocols + DIP
Se usa en:
- `NetworkClient`, `DBZCheckRepository`, `CheckDBZAnswerUseCase`, `DBZCheckRemoteDataSource`

Mini opciones:
```swift
protocol PaymentService { func pay() }
struct MockPaymentService: PaymentService { func pay() {} }

// DIP: depende de interfaz, no de clase concreta
final class CheckoutVM {
  private let service: PaymentService
  init(service: PaymentService) { self.service = service }
}
```

## 4) SRP
Se usa en:
- ViewModel maneja estado de UI
- UseCase orquesta caso de uso
- Repository coordina origen de datos
- NetworkClient hace HTTP

Mini regla:
```swift
// Si una clase cambia por dos motivos distintos, probablemente viola SRP.
```

## 5) Class vs Struct
Se usa en:
- `class`: ViewModel, UseCaseImpl, RepositoryImpl, RemoteDataSourceImpl
- `struct`: DTOs, Entity, Views

Mini opciones:
```swift
struct User { var name: String }   // valor
final class Session { var token: String = "" } // referencia
```

## 6) Access Modifiers
Se usa en:
- `private let useCase`
- `@Published private(set) var state`

Mini opciones:
```swift
public struct PublicAPI {}
internal struct ModuleOnly {}
fileprivate func fileOnly() {}
private func typeOnly() {}
open class BaseClass {}
```

## 7) Optionals + Optional Binding
Se usa en:
- `if let bodyString = String(...)`
- `if let httpResponse = response as? HTTPURLResponse`

Mini opciones:
```swift
let name: String? = "Goku"
if let n = name { print(n) }

// optional chaining
let count = name?.count

// nil-coalescing
let safe = name ?? "Unknown"
```

## 8) Closures
Se usa en:
- `Button { ... }`
- `.sink { completion in } receiveValue: { value in }`
- `.onChange { ... }`

Mini opciones:
```swift
let sum = { (a: Int, b: Int) in a + b }
let result = sum(2, 3)
```

## 9) Higher-Order Functions
Se usa en:
- `.map(DBZCheckMapper.map)`

Mini opciones extra:
```swift
let numbers = [1, 2, 3, 4]

let mapped = numbers.map { $0 * 2 }          // [2,4,6,8]
let filtered = numbers.filter { $0 % 2 == 0 } // [2,4]
let reduced = numbers.reduce(0, +)            // 10

let raw = ["1", "x", "3"]
let compact = raw.compactMap(Int.init)        // [1,3]
```

## 10) Weak vs Strong + ARC + Retain Cycles
Se usa en:
- `private weak var delegate`
- `[weak self]` en `sink`

Mini opciones:
```swift
class A { var b: B? }
class B { weak var a: A? } // rompe ciclo

// unowned: cuando garantizas vida util (usar con cuidado)
unowned let owner: Owner
```

## 11) Delegate
Se usa en:
- `NetworkClientDelegate` + `PrintNetworkClientDelegate`

Mini opciones:
```swift
protocol LoginDelegate: AnyObject { func didLogin() }
final class LoginService { weak var delegate: LoginDelegate? }
```

## 12) Combine (vs RxSwift)
Se usa en:
- `AnyPublisher`, `map`, `decode`, `sink`, `eraseToAnyPublisher`

Mini opciones extra:
```swift
publisher
  .map { $0.name }
  .filter { !$0.isEmpty }
  .replaceError(with: "N/A")
  .sink { print($0) }
  .store(in: &cancellables)
```

## 13) Concurrencia (punto actual)
Se usa en:
- `DispatchQueue.main` con `.receive(on:)`

Mini opciones:
```swift
// GCD
DispatchQueue.global().async { ... }
DispatchQueue.main.async { ... }

// Combine -> main thread para UI
.receive(on: DispatchQueue.main)
```

## 14) @StateObject y @Binding (SwiftUI)
Se usa en:
- `@StateObject private var viewModel`
- `TextField(..., text: $viewModel.inputText)`

Mini opciones:
```swift
@State private var text = ""
ChildView(text: $text) // @Binding en child
```

## 15) .onAppear y Main thread
Se usa en:
- `.onAppear { ... }`
- `.receive(on: DispatchQueue.main)`

Mini opciones:
```swift
.onAppear { print("visible") }
.task { /* trabajo async */ }
```

## 16) MainActor vs DispatchQueue.main (nota corta)
Estado actual:
- Hoy usas `DispatchQueue.main`.

Mini comparacion:
```swift
// GCD
DispatchQueue.main.async { self.state = .idle }

// Concurrency moderna
@MainActor
func updateUI() { state = .idle }
```

## Pantalla 2 (API real + async/await) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZAsync/Presentation/DBZAsyncView.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZAsync/Presentation/DBZAsyncViewModel.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZAsync/Domain/UseCases/GetDBZCharacterByNameUseCase.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZAsync/Data/Repositories/DBZCharacterRepositoryImpl.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZAsync/Data/Remote/DBZCharacterRemoteDataSource.swift`

Terminos que practica esta pantalla:
- `Async/Await`: `try await useCase.execute(...)`
- `Task`: `Task { await viewModel.submit() }`
- `MainActor`: `@MainActor final class DBZAsyncViewModel`
- `Clean Architecture`: capas `Presentation/Domain/Data`
- `MVVM`: `DBZAsyncView` + `DBZAsyncViewModel`
- `Protocols + DIP`: repositorio/use case/data source por contrato
- `DTO + Mapper`: `DBZCharacterDTO` y `DBZCharacterMapper`

Mini ejemplo del viaje (Pantalla 2):
```swift
// UI
Task { await viewModel.submit() }

// ViewModel
let character = try await useCase.execute(name: query)

// UseCase -> Repository -> Remote
let dto = try await remote.fetchCharacterByName(name)
return DBZCharacterMapper.map(dto)
```

## Pantalla 3 (State Lab) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/StateLab/Presentation/StateLabView.swift`

Terminos que practica esta pantalla:
- `@State`:
  Dato local de una vista. Si la vista cambia ese dato, SwiftUI vuelve a renderizar.
  En esta pantalla: `warriorName` y `localPowerLevel`.
- `@Binding`:
  Es una referencia al estado de otra vista (normalmente del padre).
  Sirve para que el hijo pueda leer y escribir el mismo dato, no una copia.
  En esta pantalla: `BindingChildCard` modifica el nombre y poder del padre.
- `@StateObject`:
  Se usa cuando la vista es dueña del ViewModel y debe conservarlo durante su ciclo de vida.
  En esta pantalla: el padre crea `StateLabViewModel`.
- `@ObservedObject`:
  Se usa cuando la vista recibe un ObservableObject ya creado por otra vista.
  En esta pantalla: `ObservedObjectChildCard` consume el ViewModel del padre.
- `.onAppear`:
  Se ejecuta cuando la vista entra en pantalla.
  En esta pantalla lo usamos para contar cuantas veces aparece.
- `.task(id:)`:
  Ejecuta trabajo async al aparecer la vista y vuelve a ejecutar cuando cambia el `id`.
  En esta pantalla el `id` es `taskTrigger`, para forzar nuevas ejecuciones.

Mini ejemplo del flujo (Pantalla 3):
```swift
// Padre
@State private var localPowerLevel = 0
@StateObject private var viewModel = StateLabViewModel()

// Hijo con binding
BindingChildCard(powerLevel: $localPowerLevel)

// Hijo con observed object
ObservedObjectChildCard(viewModel: viewModel)

// Ciclo de vida
.onAppear { ... }
.task(id: taskTrigger) { ... }
```

Ejemplo mental super simple:
- `@State` = "mi libreta personal" (solo esta vista).
- `@Binding` = "la misma libreta prestada al hijo" (hijo edita y padre ve cambios).
- `@StateObject` = "yo creo y mantengo a mi manager (ViewModel)".
- `@ObservedObject` = "solo observo un manager que me pasaron".

## Pantalla 4 (UIKit Lifecycle DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZLifecycle/Presentation/DBZLifecycleView.swift`

Terminos que practica esta pantalla:
- `UI Lifecycle (UIKit)`:
  `viewDidLoad`, `viewWillAppear`, `viewDidAppear`, `viewWillDisappear`, `viewDidDisappear`.
- `UI Lifecycle (SwiftUI)`:
  `.onAppear` y `.onDisappear` en la pantalla contenedora SwiftUI.
- `UIKit + SwiftUI bridge`:
  `UIViewControllerRepresentable` para montar un `UIViewController` dentro de SwiftUI.

Orden tipico que vas a ver en consola:
```swift
viewDidLoad
viewWillAppear
viewDidAppear
// al salir de la pantalla:
viewWillDisappear
viewDidDisappear
```

## Pantalla 5 (Concurrency Lab DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZConcurrency/Presentation/DBZConcurrencyView.swift`

Terminos que practica esta pantalla:
- `Task`: crear trabajo async desde UI.
- `Task.detached`: tarea separada del contexto/actor actual.
- `async let`: lanzar varias operaciones en paralelo y esperar sus resultados.
- `TaskGroup`: ejecutar un grupo dinamico de tareas concurrentes.
- `Cancellation`: `cancel()` + `Task.checkCancellation()`.
- `MainActor vs DispatchQueue.main`: dos formas de actualizar UI en main thread.
- `Actor`: `ScouterLogStore` para estado compartido sin data races.
- `Sendable`: `FighterPower` para mover datos entre tareas con seguridad.

Mini ejemplo del flujo (Pantalla 5):
```swift
// async let
async let goku = fetchPower(for: "Goku")
async let vegeta = fetchPower(for: "Vegeta")
let result = try await [goku, vegeta]

// TaskGroup
try await withThrowingTaskGroup(of: FighterPower.self) { group in
  group.addTask { try await fetchPower(for: "Broly") }
}

// Cancellation
currentTask?.cancel()
try Task.checkCancellation()
```

## Pantalla 6 (Storage Lab DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZStorage/Presentation/DBZStorageView.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZStorage/Data/DBZStorageServices.swift`

Terminos que practica esta pantalla:
- `UserDefaults`: persistencia de preferencias no sensibles.
- `Keychain`: almacenamiento de dato sensible (access code).
- `Singleton`: `DBZStorageManager.shared`.
- `Guard let / validaciones`: se valida input antes de guardar.
- `Optionals + Optional Binding`: lectura opcional desde Keychain.
- `Access Modifiers`: uso de `private` y `private(set)` en servicios/viewmodel.

Regla mental:
- Preferencias de UI -> `UserDefaults`
- Secretos/tokens/códigos -> `Keychain`

Mini ejemplo del flujo (Pantalla 6):
```swift
// UserDefaults
storage.savePreferences(...)
let prefs = storage.loadPreferences()

// Keychain
try storage.saveAccessCode(code)
let code = try storage.loadAccessCode()
```

## Pantalla 7 (Persistence Lab DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZPersistence/Presentation/DBZPersistenceView.swift`
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZPersistence/Data/DBZPersistenceStores.swift`

Terminos que practica esta pantalla:
- `Core Data`: stack + entidad + CRUD.
- `SwiftData`: `@Model`, `ModelContainer`, `ModelContext`, `FetchDescriptor`.
- `Class vs Struct`: stores como class; view data como struct.
- `Layer Boundaries`: UI no conoce detalles internos de cada motor.
- `Repository mindset`: mismo caso de uso con 2 implementaciones de persistencia.

Regla mental:
- Core Data = framework maduro y flexible.
- SwiftData = API moderna y mas simple sobre persistencia Apple.

Mini ejemplo del flujo (Pantalla 7):
```swift
// elegir motor en UI (Core Data / SwiftData)
switch selectedEngine {
case .coreData: try coreDataStore.saveSession(...)
case .swiftData: try swiftDataStore.saveSession(...)
}

// luego cargar sesiones
sessions = try store.fetchSessions()
```

## Pantalla 8 (SOLID + VIPER DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZArchitecture/Presentation/DBZArchitectureView.swift`

Terminos que practica esta pantalla:
- `VIPER`: View, Interactor, Presenter, Entity, Router.
- `SRP`: cada pieza tiene una sola responsabilidad clara.
- `DIP`: Presenter depende de protocolos, no concretos.
- `ISP`: contratos pequeños por rol (`ViewProtocol`, `InteractorProtocol`, etc).
- `OCP`: puedes extender con otro interactor/router sin romper estructura base.

Mini ejemplo del flujo (Pantalla 8):
```swift
View -> Presenter.onSearchTapped(name)
Presenter -> Interactor.findFighter(name)
Presenter -> View.showResult(...)
Presenter -> Router.routeToDetail(...)
```

## Pantalla 9 (UI Flow Lab DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZUIFlow/Presentation/DBZUIFlowView.swift`

Terminos que practica esta pantalla:
- `LazyVStack vs List`: mismo dataset DBZ en dos contenedores.
- `.task(id:) vs .onAppear`: diferencia de ejecución y re-ejecución.
- `MainActor vs DispatchQueue.main`: dos formas de actualizar UI en main thread.
- `@State`: control de filtro, modo de contenedor, contadores de ciclo.

Mini ejemplo del flujo (Pantalla 9):
```swift
.onAppear { appearCount += 1 }
.task(id: taskTrigger) { taskCount += 1 }

if mode == .list { List(...) }
else { ScrollView { LazyVStack { ... } } }
```

## Pantalla 10 (Quality Lab DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZQuality/Presentation/DBZQualityView.swift`

Terminos que practica esta pantalla:
- `Testing`: enfoque por contratos para poder testear comportamiento.
- `Test doubles`: `Stub`, `Fake/Flaky`, `Spy`.
- `Error handling`: retries con backoff exponencial.
- `Observability`: logs estructurados y trazas por intento.
- `Performance básico`: medición de duración de ejecución.
- `RxSwift` (si el paquete está instalado): `Single`, `retry`, `DisposeBag`.
- `Combine vs RxSwift`: diferencias de primitives y manejo de subscripciones.

Mini ejemplo del flujo (Pantalla 10):
```swift
let power = try await fetchWithRetry(service: service, warrior: warrior, retries: 3)
logger.log("attempt=...")
logger.log("backoff=...")

// RxSwift (opcional por canImport)
makeRxSingle(...)
  .retry(2)
  .subscribe(...)
  .disposed(by: disposeBag)
```

## Pantalla 11 (Security + Release DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZSecurityRelease/Presentation/DBZSecurityReleaseView.swift`

Terminos que practica esta pantalla:
- `Security`: certificate pinning (simulado por comparación de fingerprint).
- `Feature Flags`: activar/desactivar funcionalidad por porcentaje de rollout.
- `Release strategy`: `kill switch` y `rollback` rápido.
- `Risk control`: desactivar feature sin despliegue nuevo.

Mini ejemplo del flujo (Pantalla 11):
```swift
if expectedFingerprint == serverFingerprint { /* pinning ok */ }

let bucket = abs(userID.hashValue) % 100
featureEnabled = bucket < rolloutPercent

// rollback
rolloutPercent = 0
```

## Pantalla 12 (Delivery Lab DBZ) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZDelivery/Presentation/DBZDeliveryView.swift`

Terminos que practica esta pantalla:
- `CI/CD mindset`: quality gates antes de producción.
- `Release strategy`: decisión Ship/No-Ship basada en evidencia.
- `Feature flags + rollback`: como parte de checklist operacional.
- `Observabilidad/quality`: gate explícito para logs y métricas.
- `Engineering process`: release notes y readiness score.

Mini ejemplo del flujo (Pantalla 12):
```swift
toggleGate(...)
score = passed / total

if allGatesPassed && releaseNotesNotEmpty {
  ship = true
} else {
  ship = false
}
```

## Pantalla 13 (UIKit List Lifecycle) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZUIKitListLifecycle/Presentation/DBZUIKitListLifecycleView.swift`

Terminos que practica esta pantalla:
- `UIKit programatico`: UI creada por codigo (`UILabel`, `UISegmentedControl`, `UITableView`, constraints).
- `UIViewController Lifecycle`: `viewDidLoad` (setup + primera carga) y `viewWillAppear` (refresco liviano).
- `UITableViewDataSource`: define cantidad de filas y contenido de cada celda.
- `UITableViewDelegate`: reacciona al ciclo visual de celdas (ej. `willDisplay`).
- `UITableViewDataSourcePrefetching`: adelanta carga antes de que el usuario llegue al final.
- `UIRefreshControl`: pull-to-refresh para reconstruir y refrescar datos manualmente.
- `Eager vs Paged loading`:
  - Eager = renderiza todo de una vez (simple, pero costoso en listas grandes).
  - Paged = carga por bloques (mejor para datos masivos y scroll fluido).
- `Background thread + main thread`: dataset se construye fuera del main thread y luego se actualiza UI en main.
- `Cell reuse`: `dequeueReusableCell` para evitar costo innecesario de crear celdas nuevas.
- `Cost awareness`: evitar trabajo pesado dentro de `cellForRowAt`, medir tiempo de construccion y paginar.

Donde se construyen y refrescan los datos (en esta pantalla):
- Construccion principal: `buildDataAndRender(origin:)`.
- Refresco por cambio de estrategia: `strategyChanged()`.
- Refresco por gesto usuario: `refreshPulled()`.
- Carga incremental masiva: `loadNextPageIfNeeded(trigger:)` desde `willDisplay` y `prefetchRowsAt`.

Regla mental para decidir:
- Lista pequena/mediana y simple -> puede servir carga completa.
- Lista grande o potencialmente ilimitada -> usar paginacion + prefetch.
- Si notas drops de FPS o consumo alto -> mover transformaciones a background y reducir trabajo por celda.

Mini ejemplo del flujo (Pantalla 13):
```swift
override func viewDidLoad() {
  configureUI()
  configureTable()
  buildDataAndRender(origin: "viewDidLoad") // construccion inicial
}

@objc private func refreshPulled() {
  buildDataAndRender(origin: "pullToRefresh") // refresco manual
}

func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
  if indexPath.row >= visibleItems.count - 20 {
    loadNextPageIfNeeded(trigger: "willDisplay") // paginacion
  }
}
```

## Pantalla 14 (Instruments Leaks) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsLeaks/Presentation/DBZInstrumentsLeaksView.swift`

Terminos que practica esta pantalla:
- `Leaks`: deteccion de objetos no liberados.
- `Retain Cycle`: ciclo de retencion con `Timer` capturando `self` fuerte.
- `ARC`: diferencia entre liberar referencia temporal y mantener referencias globales.

Escenarios:
- Normal: `DBZSafeBox` usa `[weak self]` + invalidacion de timer.
- Problema: `DBZLeakyCycleBox` mantiene ciclo y se guarda en bolsa global.

Mini flujo:
```swift
viewModel.runNormal() // sin leak
viewModel.runLeak()   // leak intencional
```

## Pantalla 15 (Instruments Allocations) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsAllocations/Presentation/DBZInstrumentsAllocationsView.swift`

Terminos que practica esta pantalla:
- `Allocations`: crecimiento de heap por asignaciones.
- `Temporary vs Retained Memory`: memoria temporal que se libera vs memoria retenida.

Escenarios:
- Normal: crea bloques `Data` temporales y los libera.
- Problema: acumula bloques en arreglo retenido.

Mini flujo:
```swift
viewModel.runNormal()  // sube y baja
viewModel.runProblem() // subida sostenida
```

## Pantalla 16 (Instruments VM Tracker) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsVMTracker/Presentation/DBZInstrumentsVMTrackerView.swift`

Terminos que practica esta pantalla:
- `VM Tracker`: observacion de memoria virtual y categorias de uso.
- `NSCache`: cache con eviction para evitar crecimiento sin limite.
- `Retained Buffers`: retencion de buffers grandes en memoria.

Escenarios:
- Normal: carga objetos en `NSCache` con limite.
- Problema: guarda buffers en arreglo sin politica de eviction.

## Pantalla 17 (Instruments Time Profiler) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsTimeProfiler/Presentation/DBZInstrumentsTimeProfilerView.swift`

Terminos que practica esta pantalla:
- `Time Profiler`: hotspots de CPU por funcion.
- `Main Thread Blocking`: impacto de computo pesado en hilo principal.
- `Background Work`: mover trabajo costoso fuera del main thread.

Escenarios:
- Normal: calculo pesado en `Task.detached`.
- Problema: calculo pesado directo en main thread.

## Pantalla 18 (Instruments Core Animation) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsCoreAnimation/Presentation/DBZInstrumentsCoreAnimationView.swift`

Terminos que practica esta pantalla:
- `Core Animation`: costo de render y composicion de capas.
- `Overdraw/Effects cost`: blur, sombras y muchas capas animadas.

Escenarios:
- Normal: lista simple con pocas vistas.
- Problema: grid grande con gradientes, blur, sombras y animacion continua.

## Pantalla 19 (Instruments Network) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsNetwork/Presentation/DBZInstrumentsNetworkView.swift`

Terminos que practica esta pantalla:
- `Network Instrument`: conteo y tiempo de requests.
- `Burst traffic`: pico de trafico por concurrencia alta.
- `URLSession + TaskGroup`: requests en paralelo.

Escenarios:
- Normal: 1 request.
- Problema: burst de 20 requests concurrentes.

## Pantalla 20 (Instruments File Activity) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsFileActivity/Presentation/DBZInstrumentsFileActivityView.swift`

Terminos que practica esta pantalla:
- `File Activity`: operaciones de lectura/escritura en disco.
- `I/O Patterns`: diferencia entre acceso puntual y acceso masivo.

Escenarios:
- Normal: escribe 1 archivo.
- Problema: escribe 120 archivos y luego lee todo el directorio.

## Pantalla 21 (Instruments Energy Log) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsEnergy/Presentation/DBZInstrumentsEnergyView.swift`

Terminos que practica esta pantalla:
- `Energy Log`: costo energetico de CPU/Timers.
- `Timer frequency`: impacto de 1 Hz vs 60 Hz.

Escenarios:
- Normal: timer liviano cada segundo.
- Problema: timer 60 Hz con trabajo CPU en cada tick.

## Pantalla 22 (Instruments Concurrency) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZInstrumentsConcurrency/Presentation/DBZInstrumentsConcurrencyView.swift`

Terminos que practica esta pantalla:
- `Swift Concurrency Instrument`: visualizacion de tareas y carga concurrente.
- `TaskGroup`: concurrencia estructurada.
- `Actor`: acceso seguro a estado compartido.

Escenarios:
- Normal: pocas tareas + actor.
- Problema: explosion de 1500 tareas concurrentes.

## Pantalla 23 (Deep Link + Navigation Lab) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZDeepLinkNavigation/Presentation/DBZDeepLinkNavigationView.swift`

Terminos que practica esta pantalla:
- `Deep Link`: entrada externa a una pantalla concreta por URL.
- `NavigationStack(path:)`: navegacion programatica basada en estado.
- `Route Parsing`: validacion de esquema, host y payload de la ruta.
- `Error handling`: manejo de rutas invalidas sin romper la UI.

Escenarios:
- Normal: abrir `dragonball://fighter/goku` o `dragonball://tournament/7`.
- Problema: enviar una ruta invalida como `dragonball://planet/namek`.

## Pantalla 24 (DI Container + Module Assembly) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZDIContainer/Presentation/DBZDIContainerView.swift`

Terminos que practica esta pantalla:
- `Dependency Injection`: inyeccion por constructor y por composition root.
- `DI Container`: fabrica simple que arma el modulo segun el entorno.
- `Environment switching`: cambio entre implementacion `live` y `mock`.
- `Module Assembly`: la vista no conoce la implementacion concreta del repositorio.

Escenarios:
- Normal: resolver dependencias en `live`.
- Comparacion: cambiar a `mock` sin tocar la vista ni el caso de uso.

## Pantalla 25 (Testing Lab Real) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZTestingLab/Presentation/DBZTestingLabView.swift`

Terminos que practica esta pantalla:
- `Unit testing mindset`: validar comportamiento, no solo ejecutar codigo.
- `Test doubles`: servicio determinista y servicio que falla.
- `Happy path / Boundary / Failure path`: tres tipos basicos de prueba.
- `UseCase testing`: probar la logica del caso de uso aislada de infraestructura real.

Escenarios:
- Caso feliz: `goku` debe rankear `S`.
- Boundary: `krillin` cae en rango `B`.
- Error path: servicio fallando para validar manejo de errores.

## Pantalla 26 (GraphQL + Apollo Lab) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZGraphQLApollo/Presentation/DBZGraphQLApolloView.swift`

Terminos que practica esta pantalla:
- `GraphQL`: pedir exactamente los campos que necesita la UI.
- `HTTP POST GraphQL`: enviar `query` + `variables` en JSON.
- `UseCase + Repository`: mantener separado el acceso remoto de la UI.
- `Apollo readiness`: dejar el modulo listo para migrar a Apollo + codegen.

Endpoint consultado:
- `https://dokkanapi.azurewebsites.net/graphql`

Query usada en la pantalla:
```graphql
query SearchCharacters($name: String!) {
  characters(name: $name) {
    id
    name
    title
  }
}
```

Escenarios:
- Normal: buscar `broly`, `raditz` o `cooler`.
- Error: nombre vacio o respuesta GraphQL con errores.
- Evolucion senior: reemplazar parseo manual por Apollo SDK + tipos generados desde schema.

## Pantalla 27 (Offline First + Sync) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZOfflineSync/Presentation/DBZOfflineSyncView.swift`

Terminos que practica esta pantalla:
- `Offline-first`: mostrar cache local antes de depender de red.
- `Stale-while-revalidate`: servir cache y luego actualizar en segundo plano.
- `Repository pattern`: coordinar cache local y fuente remota.
- `Sync mindset`: separar lectura inmediata de revalidacion remota.

Escenarios:
- Normal: cargar datos locales al instante.
- Normal mejorado: mostrar cache y luego refrescar remoto.
- Riesgo controlado: si falla remoto, la UI conserva cache.

## Pantalla 28 (Background Tasks Lab) - resumen rapido
Se usa en:
- `DragonBallAndrewVeran/DragonBallAndrewVeran/Features/DBZBackgroundTasks/Presentation/DBZBackgroundTasksView.swift`

Terminos que practica esta pantalla:
- `BackgroundTasks`: framework de iOS para trabajo diferido.
- `BGAppRefreshTaskRequest`: request para refresh en background.
- `Pending work queue`: mantener trabajos pendientes fuera del flujo inmediato de UI.
- `Scheduling vs execution`: una cosa es agendar y otra realmente ejecutar.

Escenarios:
- Normal: agendar refresh.
- Normal: ejecutar una sync simulada y vaciar parte de la cola.
- Evolucion senior: registrar identificadores en `Info.plist` y `App` para scheduling real.
