//
//  MVVMGokuViewModel.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

/// ViewData mínimo: solo 2-3 datos para el demo.
struct MVVMCharacterViewData: Identifiable {
    let id: String
    let name: String
    let race: String
    let imageURL: URL?
    let ki: String
}

final class MVVMGokuViewModel: ObservableObject {
    @Published private(set) var state: Loadable<MVVMCharacterViewData> = .idle

    private let service: MVVMDragonBallServiceType
    private var cancellables = Set<AnyCancellable>()

    init(service: MVVMDragonBallServiceType) {
        self.service = service
    }

    func load() {
        // [MVVM-1] UI dispara la intención: “cargar Goku”
        state = .loading

        service.fetchCharacterByName("goku")
            // [MVVM-2] respuesta llega al ViewModel (Combine pipeline)
            .map { dto -> MVVMCharacterViewData in
                // [MVVM-3] mapeo DTO → ViewData (lo que la UI necesita)
                let name = dto.name ?? "Unknown"
                let race = dto.race ?? "?"
                let ki = dto.ki ?? "?"
                let imageURL = URL(string: dto.image ?? "")
                return MVVMCharacterViewData(
                    id: String(dto.id ?? -1),
                    name: name,
                    race: race,
                    imageURL: imageURL,
                    ki: ki
                )
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // [MVVM-4] manejamos error / fin
                if case let .failure(error) = completion {
                    self?.state = .failed(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] viewData in
                // [MVVM-5] publicamos estado para que SwiftUI renderice
                self?.state = .loaded(viewData)
            }
            .store(in: &cancellables)
    }
}
