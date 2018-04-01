//
//  MoveAlongPathComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

protocol MoveAlongPathDelegate {
    func didReachEnd()
}

final class MoveAlongPathComponent<EntityType: EntityWithPosition & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent, MoveableComponent {
    
    /**
        units per second to move along the path
     */
    var speed = Scalar()
    
    var throttle = Scalar()
    
    var currentSpeed: Scalar {
        return max(speed - throttle, 0)
    }
    
    /**
     direction of the movement, must be normalized
     */
    var direction: Vector {
        get {
            return pathPosition?.direction ?? Vector()
        }
        set {
            //can't set the direction
        }
    }
    var velocity: Vector {
        get {
            return direction * currentSpeed
        }
    }
    fileprivate var pathPosition: VectorPathPosition?
    fileprivate var path: VectorPath?
    
    var distanceToDestination: Scalar {
        guard let totalPathLength = path?.length, let distanceMoved = pathPosition?.distanceMoved else {
            return 0
        }
        return totalPathLength - distanceMoved
    }
    
    var delegate: MoveAlongPathDelegate?
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    func moveAlongPath(_ path: VectorPath) {
        pathPosition = VectorPathPosition(origin: entity.position)
        self.path = path
    }
    
    func stop() {
        self.path = nil
    }
    
    let updateStep = UpdateStep.simulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        
        guard let path = path else {
            return
        }
        let distance = currentSpeed * seconds
        
        pathPosition?.moveAlongPath(path, length: distance)
        
        updateEntityPosition()
        
        if let pathPosition = pathPosition {
            if pathPosition.didReachEnd(path) {
                delegate?.didReachEnd()
            }
        }
    }
    
    fileprivate func updateEntityPosition() {
        guard let pathPosition = pathPosition else {
            return
        }
        entity.position = pathPosition.position
    }
    
    func estimatedVelocity(after seconds: TimeInterval) -> Vector {
        return velocity
    }
    
    func estimatedPosition(after seconds: TimeInterval) -> Vector {
        guard let path = path,
            var pathPosition = self.pathPosition else {
                
            return entity.position
        }
        
        let distance = currentSpeed * seconds
        pathPosition.moveAlongPath(path, length: distance)
        return pathPosition.position
    }
}
