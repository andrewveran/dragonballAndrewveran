//
//  CA.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import SwiftUI

struct CAGokuView: View {
    @StateObject private var vm: CAGokuViewModel

    init() {
        // “Composition Root” manual (para que se vea el wiring):
        let http = URLSessionHTTPClient(delegate: PrintHTTPClientDelegate())
        let remote = DragonBallRemoteDataSource(http: http)
        let repo = CharacterRepositoryImpl(remote: remote)
        let useCase = GetCharacterByNameUseCaseImpl(repository: repo)
        _vm = StateObject(wrappedValue: CAGokuViewModel(useCase: useCase))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Clean Architecture Journey")
                .font(.title.bold())

            content

            Button("Recargar") {
                // [CA-UI-1] UI dispara intención
                vm.load()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            // [CA-UI-0] carga inicial
            vm.load()
        }
        .navigationTitle("Clean")
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle:
            Text("Idle…")
        case .loading:
            ProgressView("Cargando Goku…")
        case .failed(let message):
            Text("Error: \(message)")
                .foregroundStyle(.red)
        case .loaded(let goku):
            NavigationLink {
                CAGokuDetailView(goku: goku)
            } label: {
                HStack(spacing: 12) {
                    AsyncImage(url: goku.imageURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(goku.name).font(.headline)
                        Text("Raza: \(goku.race)")
                        Text("Ki: \(goku.ki)")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}
