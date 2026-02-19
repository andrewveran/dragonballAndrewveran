//
//  Untitled.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import SwiftUI

struct CAGokuDetailView: View {
    let goku: CACharacterViewData

    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: goku.imageURL) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 220)

            Text(goku.name).font(.largeTitle.bold())
            Text("Raza: \(goku.race)")
            Text("Ki: \(goku.ki)")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Detalle")
    }
}
