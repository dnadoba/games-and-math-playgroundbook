//
//  AcceleratedMotionComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

protocol EntityWithAcceleratedMovement: EntityWithMovement, EntityWithUpdatableComponents {
    var movement: AcceleratedMovementComponent<Self> { get }
}

final class AcceleratedMovementComponent<EntityType: EntityWithPosition & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent, MoveableComponent {
    /**
     movement speed in units per second
     */
    var speed: Scalar {
        get {
            return velocity.length
        }
        set {
            velocity = velocity.normalized * newValue
        }
    }
    //not supported...
    var throttle = Scalar()
    
    var currentSpeed: Scalar {
        return max(speed, 0)
    }
    
    /**
     direction of the entity, must be normalized
     */
    var direction: Vector {
        get {
            return velocity.normalized
        }
        set {
            velocity = newValue * speed
        }
    }
    /**
     velocity in units per second
     */
    fileprivate(set) var velocity = Vector()
    /**
     acceleration in units per seconds^2
     */
    var acceleration = Vector()
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    func apply(_ velocity: Vector){
        self.velocity += velocity
    }
    
    let updateStep = UpdateStep.simulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        //v(t) = a * t
        velocity += acceleration * seconds
        //s(t) = v*t
        //s(t) = v*t +1/2at^2
        entity.position += velocity * seconds
    }
    
    func estimatedVelocity(after seconds: TimeInterval) -> Vector {
        return velocity + acceleration * seconds
    }
    
    func estimatedPosition(after seconds: TimeInterval) -> Vector {
        return entity.position + estimatedVelocity(after: seconds) * seconds
    }
}
