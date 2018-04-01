//
//  Lane.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 26.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

struct Lane {
    let ways: [Way]
    
    init(ways: [Way]) {
        guard ways.count > 0 else {
            fatalError("a lane requires at least one way")
        }
        self.ways = ways
    }
    
    var primaryWay: Way {
        //middle way
        let index = Int((ways.count - 1) / 2)
        
        return ways[index]
    }
    
    var origin: Vector {
        return primaryWay.origin
    }
}