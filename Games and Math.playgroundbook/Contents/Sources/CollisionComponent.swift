//
//  CollisionComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 24.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

protocol CollidableEntity: EntityWithShapeComponent, EntityWithPosition {
    
}

extension CollidableEntity {
    func intersect(withEntity entity: CollidableEntity) -> Bool {
        switch (self.shape, entity.shape){
        case (.circle(let selfRadius), .circle(let entityRadius)):
            let distance = self.position.distanceTo(entity.position)
            let maxDistanceToIntersect = selfRadius + entityRadius
            return distance <= maxDistanceToIntersect
        default:
            fatalError("shape intersection is not implementet with a shape \(self.shape) and \(entity.shape)")
        }
    }
}

protocol CollisionDelegate: class {
    func didCollide(withTarget entity: CollidableEntity)
}

final class CollisionComponent<EntityType: CollidableEntity & EntityWithMovement & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent {
    
    weak var delegate: CollisionDelegate?
    weak var target: CollidableEntity?
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.didSimulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        guard let collidableEntity = target else {
            return
        }
        
        if self.entity.intersect(withEntity: collidableEntity) {
            delegate?.didCollide(withTarget: collidableEntity)
        }
    }
    
}
