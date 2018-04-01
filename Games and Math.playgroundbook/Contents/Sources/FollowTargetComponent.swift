//
//  FollowTargetComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd

final class FollowTargetComponent<EntityType: EntityWithMovement & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent {
    
    weak var target: EntityWithPosition?
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.willSimulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        guard let entityToFollow = target else {
            return
        }
        entity.movement.direction = (entityToFollow.position - entity.position).normalized
    }
}
