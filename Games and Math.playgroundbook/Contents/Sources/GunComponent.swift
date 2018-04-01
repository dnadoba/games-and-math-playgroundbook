//
//  GunComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 24.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

protocol GunComponentDelegate: class {
    func shot(atEntity target: TargetableEntity, fromPosition startPosition: Vector)
}

final class GunComponent<GameType: GameWithTargetableSystem, EntityType: EntityWithGame & EntityWithPosition & EntityWithUpdatableComponents>: BasicComponentWithGame<GameType, EntityType>, UpdatableComponent where EntityType.GameType == GameType {
    
    /**
        fire rate in seconds. how often an entity can shot per second
     */
    var fireRate = Scalar()
    /**
        radius around the entity in which entities can be shot
     */
    var range: Scalar {
        get { return sqrt(rangeSquared) }
        set { rangeSquared = newValue * newValue }
    }
    /**
     squared radius around the entity in which entities can be shot
     */
    var rangeSquared = Scalar()
    /**
        offset of the gun component. used to determine if an entity is in range and is used for the start position of the bullet
     */
    var offset = Vector()
    
    weak var delegate: GunComponentDelegate?
    
    fileprivate var position: Vector {
        return entity.position + offset
    }
    
    fileprivate var timeElapsedSinceLastShot = Scalar(0)
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.willSimulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        timeElapsedSinceLastShot += seconds
        guard timeElapsedSinceLastShot > fireRate else {
            return
        }
        
        guard let delegate = delegate else {
            return
        }
        
        if let target = game?.targetableSystem.getTarget(fromPosition: position, inRangeSquared: rangeSquared) {
            timeElapsedSinceLastShot = 0
            delegate.shot(atEntity: target, fromPosition: position)
        }
    }
}
