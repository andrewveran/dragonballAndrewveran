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
import Foundation
import CoreData
import SwiftData

struct DBZTrainingSessionViewData: Identifiable, Equatable {
    let id: UUID
    let warrior: String
    let minutes: Int
    let createdAt: Date
    let source: String
}

// MARK: - Core Data Store

final class DBZCoreDataStore {
    private let container: NSPersistentContainer

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DBZCoreDataModel", managedObjectModel: Self.makeModel())

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                print("[PERSISTENCE][CORE_DATA] load store error=\(error.localizedDescription)")
            }
        }
    }

    /// FUNC-GUIDE: saveSession
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: saveSession
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func saveSession(warrior: String, minutes: Int) throws {
        let context = container.viewContext
        let object = NSEntityDescription.insertNewObject(forEntityName: "CoreDBZTraining", into: context)
        object.setValue(UUID(), forKey: "id")
        object.setValue(warrior, forKey: "warrior")
        object.setValue(minutes, forKey: "minutes")
        object.setValue(Date(), forKey: "createdAt")
        try context.save()
    }

    /// FUNC-GUIDE: fetchSessions
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: fetchSessions
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func fetchSessions() throws -> [DBZTrainingSessionViewData] {
        let context = container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CoreDBZTraining")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let objects = try context.fetch(request)
        return objects.compactMap { object in
            guard let id = object.value(forKey: "id") as? UUID,
                  let warrior = object.value(forKey: "warrior") as? String,
                  let createdAt = object.value(forKey: "createdAt") as? Date else {
                return nil
            }

            let minutes = object.value(forKey: "minutes") as? Int ?? 0
            return DBZTrainingSessionViewData(
                id: id,
                warrior: warrior,
                minutes: minutes,
                createdAt: createdAt,
                source: "Core Data"
            )
        }
    }

    /// FUNC-GUIDE: clearAll
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: clearAll
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func clearAll() throws {
        let context = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDBZTraining")
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(delete)
        try context.save()
    }

    /// FUNC-GUIDE: makeModel
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "CoreDBZTraining"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let warrior = NSAttributeDescription()
        warrior.name = "warrior"
        warrior.attributeType = .stringAttributeType
        warrior.isOptional = false

        let minutes = NSAttributeDescription()
        minutes.name = "minutes"
        minutes.attributeType = .integer64AttributeType
        minutes.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        entity.properties = [id, warrior, minutes, createdAt]
        model.entities = [entity]
        return model
    }
}

// MARK: - SwiftData Store

@Model
final class SwiftDBZTrainingSession {
    var id: UUID
    var warrior: String
    var minutes: Int
    var createdAt: Date

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(id: UUID = UUID(), warrior: String, minutes: Int, createdAt: Date = .now) {
        self.id = id
        self.warrior = warrior
        self.minutes = minutes
        self.createdAt = createdAt
    }
}

final class DBZSwiftDataStore {
    private let container: ModelContainer
    private let context: ModelContext

    /// FUNC-GUIDE: init
    /// - Que hace: construye la instancia e inyecta dependencias iniciales.
    /// - Entrada/Salida: recibe dependencias/estado y deja el objeto listo para usarse.
    /// FUNC-GUIDE: init
    /// - Qué hace: inicializa dependencias y estado base del tipo.
    /// - Entrada/Salida: recibe configuración inicial y deja la instancia lista.
    init(inMemory: Bool = false) throws {
        let config = ModelConfiguration("DBZSwiftDataModel", isStoredInMemoryOnly: inMemory)
        container = try ModelContainer(for: SwiftDBZTrainingSession.self, configurations: config)
        context = ModelContext(container)
    }

    /// FUNC-GUIDE: saveSession
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: saveSession
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func saveSession(warrior: String, minutes: Int) throws {
        let session = SwiftDBZTrainingSession(warrior: warrior, minutes: minutes)
        context.insert(session)
        try context.save()
    }

    /// FUNC-GUIDE: fetchSessions
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: fetchSessions
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func fetchSessions() throws -> [DBZTrainingSessionViewData] {
        let descriptor = FetchDescriptor<SwiftDBZTrainingSession>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let rows = try context.fetch(descriptor)
        return rows.map {
            DBZTrainingSessionViewData(
                id: $0.id,
                warrior: $0.warrior,
                minutes: $0.minutes,
                createdAt: $0.createdAt,
                source: "SwiftData"
            )
        }
    }

    /// FUNC-GUIDE: clearAll
    /// - Que hace: ejecuta una parte del flujo de esta capa (UI, dominio, datos o infraestructura).
    /// - Entrada/Salida: revisa parametros y retorno para entender como viaja el dato.
    /// FUNC-GUIDE: clearAll
    /// - Qué hace: ejecuta este bloque de lógica dentro de su capa actual.
    /// - Entrada/Salida: revisa parámetros y retorno para seguir el viaje del dato.
    func clearAll() throws {
        let rows = try context.fetch(FetchDescriptor<SwiftDBZTrainingSession>())
        for row in rows {
            context.delete(row)
        }
        try context.save()
    }
}
