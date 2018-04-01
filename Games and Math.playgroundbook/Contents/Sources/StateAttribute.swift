//
//  StateAttribute.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 08.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol EntityWithAllStateAttributes: EntityWithHealthAttribute, EntityWithMovement {}

enum StateAttribute {
    case health
    case throttle
    //case Moveable
    //case AttackSpeed
    //case Attackable
    func change<EntityType: EntityWithAllStateAttributes>(onEnitty entity: EntityType, by amount: Scalar, fromSource source: StateEffectSource) {
        switch self{
        case .health: entity.health.applyDamage(amount, fromSource: source)
        case .throttle: entity.movement.throttle -= amount
        }
    }
}
