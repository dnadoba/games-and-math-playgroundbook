//
//  BasicSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 21.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

class BasicSystem: System {
    init() {
        initComponents()
    }
    
    func initComponents() {}
    func addEntity(_ entity: Entity) {}
    func removeEntity(_ entity: Entity) {}
}

class BasicSystemWithGame<GameType: Game>: BasicSystem, SystemWithGame {
    weak var game: GameType?
    
    func added(to game: GameType) {}
    func removed(from game: GameType) {}
}
