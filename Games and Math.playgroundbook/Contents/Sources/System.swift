//
//  System.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.01.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol System: Entity {
    func addEntity(_ entity: Entity)
    func removeEntity(_ entity: Entity)
}

protocol SystemWithGame: System, EntityWithGame {}
