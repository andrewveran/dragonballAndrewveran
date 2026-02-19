//
//  RootView.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MVVMGokuView()
            }
            .tabItem { Label("MVVM", systemImage: "square.stack.3d.up") }

            NavigationStack {
                CAGokuView()
            }
            .tabItem { Label("Clean", systemImage: "circle.hexagongrid") }
        }
    }
}
