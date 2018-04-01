//
//  LanePrototype.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

final class LanePrototype: Prototype {
    fileprivate struct Key {
        static let waves = PrototypeKey<[NSDictionary]>("waves")
    }
    
    let itemIndex: Int
    let name: String
    var prototype: LanePrototype?
    
    let values: NSDictionary
    
    func validateKeys() -> [String?] {
        let errors = [
            validateKey(Key.waves),
            ]
        
        return errors
    }
    
    fileprivate var wavesPropertyList: [NSDictionary] {
        return valueForKey(Key.waves)
    }
    
    var wavePrototypeList: PrototypeList<WavePrototype> {
        return PrototypeList<WavePrototype>(withPropertyList: wavesPropertyList, inPrototype: self.description)
    }
    
    required init(itemIndex: Int, name: String, values: NSDictionary) {
        self.itemIndex = itemIndex
        self.name = name
        self.values = values
    }
}
