//
//  Entity.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol Entity: class {
    
}

func ==<T: Entity>(rhs: T, lhs: T) -> Bool {
    return false
}

protocol EntityWithGame: Entity {
    associatedtype GameType: Game
    
    //should be weak
    var game: GameType? { get set }
    
    func added(to game: GameType)
    func removed(from game: GameType)
}

extension EntityWithGame {
    func removeFromGame() {
        game?.removeEntityWithGame(self)
    }
}

extension Array where Element: Entity {
    mutating func remove(_ entity: Entity) {
        self = self.filter { $0 !== entity }
    }
}
