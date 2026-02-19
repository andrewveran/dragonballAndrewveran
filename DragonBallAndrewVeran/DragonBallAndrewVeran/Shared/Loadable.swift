//
//  Loadable.swift
//  DragonBallAndrewVeran
//
//  Created by Jorge Andres Leal Bernal on 18/02/26.
//

import Foundation

enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)
}

