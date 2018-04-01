//
//  EnemyPrototypeList.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol GameWithEnemyPrototypeList: Game {
    var enemyPrototypeList: PrototypeList<EnemyPrototype> { get }
}

final class EnemyPrototype: Prototype {
    
    fileprivate struct Key {
        static let speed = PrototypeKey<Scalar>("speed")
        static let hitpoints = PrototypeKey<Scalar>("hitpoints")
        static let texture = PrototypeKey<String>("texture")
    }
    
    let itemIndex: Int
    let name: String
    var prototype: EnemyPrototype?
    
    let values: NSDictionary
    
    func validateKeys() -> [String?] {
        return [
            validateKey(Key.speed),
            validateKey(Key.hitpoints),
            validateKey(Key.texture),
        ]
    }
    
    var speed: Scalar {
        return valueForKey(Key.speed)
    }
    
    var hitpoints: Double {
        return valueForKey(Key.hitpoints)
    }
    
    var texture: String {
        return valueForKey(Key.texture)
    }
    
    required init(itemIndex: Int, name: String, values: NSDictionary) {
        self.itemIndex = itemIndex
        self.name = name
        self.values = values
    }
}
