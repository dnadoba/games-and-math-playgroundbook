//
//  HealthAttributeComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 02.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol EntityWithHealthAttribute: Entity, HealthAttributeDelegate {
    var health: HealthAttributeComponent<Self> { get }
}

protocol HealthAttributeDelegate: class{
    func didTakeDamage(_ amount: Scalar, fromSource: Entity)
    func didDie(withLastHitFromSource source: Entity)
}

final class HealthAttributeComponent<EntityType: Entity & HealthAttributeDelegate>: BasicComponent<EntityType> {
    
    weak var delegte: HealthAttributeDelegate?
    
    fileprivate(set) var maxHitPoints = Scalar(1)
    /**
     current hit points, can be less than 0
     */
    fileprivate(set) var hitPoints = Scalar(1)
    
    var inPercentage: Scalar {
        return hitPoints/maxHitPoints
    }
    
    var isAlive: Bool {
        return !isDead && hitPoints > 0
    }
    
    //private state to deleagte didDie event only once
    fileprivate var isDead: Bool = true
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        delegte = entity
    }
    
    func reset(withHitPoints maxHitPoints: Double) {
        self.maxHitPoints = maxHitPoints
        self.hitPoints = maxHitPoints
        self.isDead = false
    }
    
    func change(by amount: Scalar, fromSource source: StateEffectSource) {
        hitPoints += amount
        
        if hitPoints <= 0 && !isDead {
            didDie(withLastHitFromSource: source)
        }
    }
    
    func applyDamage(_ amount: Scalar, fromSource source: Entity) {
        hitPoints -= amount
        
        if hitPoints <= 0 && !isDead {
            didDie(withLastHitFromSource: source)
        }
    }
    
    fileprivate func didDie(withLastHitFromSource source: Entity) {
        isDead = true
        delegte?.didDie(withLastHitFromSource: source)
    }
}
