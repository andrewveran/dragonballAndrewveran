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
import Combine

/// Abstraccion de red (DIP): las capas de Data dependen de este contrato,
/// no de URLSession directo.
protocol NetworkClient {
    func post<Request: Encodable, Response: Decodable>(
        _ url: URL,
        body: Request,
        as type: Response.Type
    ) -> AnyPublisher<Response, Error>
}

/// Delegate opcional para observar el ciclo de vida de la request.
///
/// Senior interview note:
/// - Delegate + weak evita retain cycle cuando hay referencias cruzadas.
protocol NetworkClientDelegate: AnyObject {
    func networkDidStart(_ request: URLRequest)
    func networkDidFinish(_ request: URLRequest, statusCode: Int?)
    func networkDidFail(_ request: URLRequest, error: Error)
}

/// Implementacion de logging para estudiar el flujo.
final class PrintNetworkClientDelegate: NetworkClientDelegate {
    func networkDidStart(_ request: URLRequest) {
        print("[NETWORK][START] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
    }

    func networkDidFinish(_ request: URLRequest, statusCode: Int?) {
        print("[NETWORK][FINISH] status=\(statusCode.map(String.init) ?? "nil")")
    }

    func networkDidFail(_ request: URLRequest, error: Error) {
        print("[NETWORK][FAIL] error=\(error.localizedDescription)")
    }
}

/// Cliente real basado en URLSession + Combine.
final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    /// weak para no retener fuertemente el logger/delegate.
    private weak var delegate: NetworkClientDelegate?

    init(session: URLSession = .shared, delegate: NetworkClientDelegate?) {
        self.session = session
        self.delegate = delegate
    }

    func post<Request: Encodable, Response: Decodable>(
        _ url: URL,
        body: Request,
        as type: Response.Type
    ) -> AnyPublisher<Response, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // Serializamos el body Encodable a JSON.
            request.httpBody = try JSONEncoder().encode(body)
            if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("[NETWORK][BODY] \(bodyString)")
            }
        } catch {
            // Si falla el encode, devolvemos un publisher que falla inmediatamente.
            delegate?.networkDidFail(request, error: error)
            return Fail(error: error).eraseToAnyPublisher()
        }

        delegate?.networkDidStart(request)

        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                let httpResponse = response as? HTTPURLResponse
                self?.delegate?.networkDidFinish(request, statusCode: httpResponse?.statusCode)

                // Validacion minima de status HTTP.
                guard let httpResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    print("[NETWORK][RESPONSE_BODY] \(responseString)")
                }

                return data
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .mapError { [weak self] error in
                // Centralizamos el log de fallos de red/decoding.
                self?.delegate?.networkDidFail(request, error: error)
                return error
            }
            .eraseToAnyPublisher()
    }
}
