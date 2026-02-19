//
//  MVVMGokuView.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import SwiftUI

struct MVVMGokuView: View {
    @StateObject private var vm: MVVMGokuViewModel

    init() {
        // Inyección “manual” para que se vea claro el viaje:
        let http = URLSessionHTTPClient(delegate: PrintHTTPClientDelegate())
        let service = MVVMDragonBallService(http: http)
        _vm = StateObject(wrappedValue: MVVMGokuViewModel(service: service))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("MVVM Journey")
                .font(.title.bold())

            content

            Button("Recargar") {
                // [MVVM-UI-1] Usuario toca → UI llama al ViewModel
                vm.load()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            // [MVVM-UI-0] La vista aparece → disparo carga inicial
            vm.load()
        }
        .navigationTitle("MVVM")
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
                MVVMGokuDetailView(goku: goku)
            } label: {
                HStack(spacing: 12) {
                    AsyncImage(url: goku.imageURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
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
