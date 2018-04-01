//
//  WavePrototype.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

final class WavePrototype: Prototype {
    fileprivate struct Key {
        static let distanceBetweenSquads = OptionalPrototypeKey<Scalar>("distanceBetweenSquads")
        static let waitDurationBetweenSquads = OptionalPrototypeKey<Scalar>("waitDurationBetweenSquads")
        static let squads = PrototypeKey<[String]>("squads")
    }
    
    let itemIndex: Int
    let name: String
    var prototype: WavePrototype?
    
    let values: NSDictionary
    
    func validateKeys() -> [String?] {
        return [
            validateKey(Key.distanceBetweenSquads),
            validateKey(Key.waitDurationBetweenSquads),
            validateKey(Key.squads)
        ]
    }
    
    fileprivate var distanceBetweenSquads: Scalar? {
        return valueForKey(Key.distanceBetweenSquads)
    }
    fileprivate var waitDurationBetweenSquads: Scalar? {
        return valueForKey(Key.waitDurationBetweenSquads)
    }
    
    var delayBetweenSquads: EntitySpawnDelay {
        if let distance = distanceBetweenSquads {
            return .distanceToPrevious(distance)
        } else if let delay = waitDurationBetweenSquads {
            return .WaitDuration(delay)
        } else {
            return .immediately
        }
    }
    
    var squads: [EntitySpawnSquad] {
        
        return valueForKey(Key.squads).enumerated().map { (index, squadName) in
            let isFirstSquad = (index == 0)
            let startDelay = isFirstSquad ? EntitySpawnDelay.immediately : delayBetweenSquads
            
            return EntitySpawnSquad(fileNamed: squadName, startDelay: startDelay)
        }
    }
    
    required init(itemIndex: Int, name: String, values: NSDictionary) {
        self.itemIndex = itemIndex
        self.name = name
        self.values = values
    }
}
