//
//  MovementComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

final class LinearMovementComponent<EntityType: EntityWithPosition & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent, MoveableComponent {
    
    /**
        movement speed in units per second
    */
    var speed = Scalar()
    
    var throttle = Scalar()
    
    var currentSpeed: Scalar {
        return max(speed - throttle, 0)
    }
    
    /**
        direction of the entity, must be normalized
    */
    var direction = Vector()
    
    
    
    
    /**
        velocity per second
    */
    var velocity: Vector {
        get {
            return currentSpeed * direction
        }
    }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.simulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        entity.position += velocity * seconds
    }
    
    func estimatedPosition(after seconds: TimeInterval) -> Vector {
        return entity.position + velocity * seconds
    }
    func estimatedVelocity(after seconds: TimeInterval) -> Vector {
        return velocity
    }
}

