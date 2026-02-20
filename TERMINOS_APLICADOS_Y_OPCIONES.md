# Terminos aplicados y opciones (mini guia)

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
