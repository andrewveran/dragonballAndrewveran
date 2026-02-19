//
//  CAGokuViewModel.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation
import Combine

struct CACharacterViewData: Identifiable {
    let id: String
    let name: String
    let race: String
    let ki: String
    let imageURL: URL?
}

final class CAGokuViewModel: ObservableObject {
    @Published private(set) var state: Loadable<CACharacterViewData> = .idle

    private let useCase: GetCharacterByNameUseCase
    private var cancellables = Set<AnyCancellable>()

    init(useCase: GetCharacterByNameUseCase) {
        self.useCase = useCase
    }

    func load() {
        // [CA-1] UI → ViewModel (intención)
        state = .loading

        // [CA-2] ViewModel llama al UseCase (no al repo directo)
        useCase.execute(name: "goku")
            .map { character -> CACharacterViewData in
                // [CA-4] Domain Entity → ViewData (Presentation)
                CACharacterViewData(
                    id: String(character.id),
                    name: character.name,
                    race: character.race,
                    ki: character.ki,
                    imageURL: character.imageURL
                )
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.state = .failed(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] viewData in
                // [CA-8] SwiftUI re-render por @Published
                self?.state = .loaded(viewData)
            }
            .store(in: &cancellables)
    }
}
