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
import Security

/// Modelo simple de preferencias no sensibles.
struct DBZProfilePreferences {
    let favoriteWarrior: String
    let preferredTransformation: String
}

/// UserDefaults para datos NO sensibles.
///
/// Senior note:
/// - UserDefaults es ideal para flags/preferencias, no para secretos.
final class DBZUserDefaultsStore {
    private let defaults: UserDefaults

    private enum Keys {
        static let favoriteWarrior = "dbz.favoriteWarrior"
        static let preferredTransformation = "dbz.preferredTransformation"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(preferences: DBZProfilePreferences) {
        defaults.set(preferences.favoriteWarrior, forKey: Keys.favoriteWarrior)
        defaults.set(preferences.preferredTransformation, forKey: Keys.preferredTransformation)
    }

    func load() -> DBZProfilePreferences {
        let warrior = defaults.string(forKey: Keys.favoriteWarrior) ?? ""
        let transformation = defaults.string(forKey: Keys.preferredTransformation) ?? ""
        return DBZProfilePreferences(favoriteWarrior: warrior, preferredTransformation: transformation)
    }

    func clear() {
        defaults.removeObject(forKey: Keys.favoriteWarrior)
        defaults.removeObject(forKey: Keys.preferredTransformation)
    }
}

/// Keychain para datos sensibles.
///
/// Guardamos un "scouter access code" como ejemplo de secreto.
final class DBZKeychainStore {
    private let service = "com.dragonballAndrewveran.storage"
    private let account = "scouter_access_code"

    func save(code: String) throws {
        guard let data = code.data(using: .utf8) else {
            throw NSError(domain: "DBZKeychainStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo codificar el access code"])
        }

        // Si existe lo borramos para hacer upsert simple.
        _ = delete()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: "DBZKeychainStore", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain save failed: \(status)"])
        }
    }

    func load() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw NSError(domain: "DBZKeychainStore", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Keychain load failed: \(status)"])
        }

        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    @discardableResult
    func delete() -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        return SecItemDelete(query as CFDictionary)
    }
}

/// Singleton para demo didactica.
///
/// Senior note:
/// - Util cuando necesitas una unica instancia global.
/// - Evita abusarlo; para testabilidad suele preferirse DI.
final class DBZStorageManager {
    static let shared = DBZStorageManager()

    private let defaultsStore = DBZUserDefaultsStore()
    private let keychainStore = DBZKeychainStore()

    private init() {}

    func savePreferences(_ preferences: DBZProfilePreferences) {
        defaultsStore.save(preferences: preferences)
    }

    func loadPreferences() -> DBZProfilePreferences {
        defaultsStore.load()
    }

    func clearPreferences() {
        defaultsStore.clear()
    }

    func saveAccessCode(_ code: String) throws {
        try keychainStore.save(code: code)
    }

    func loadAccessCode() throws -> String? {
        try keychainStore.load()
    }

    func deleteAccessCode() {
        _ = keychainStore.delete()
    }
}
