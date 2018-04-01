//
//  TargetableSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 04.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol TargetableEntity: EffectableEntity, CollidableEntity {
    var isTargetable: Bool { get }
    var distanceToDestination: Scalar { get }
    
    func estimatedPosition(after seconds: TimeInterval) -> Vector
    func estimatedVelocity(after seconds: TimeInterval) -> Vector
}

extension EntityWithMovement {
    func estimatedPosition(after seconds: TimeInterval) -> Vector {
        return movement.estimatedPosition(after: seconds)
    }
    func estimatedVelocity(after seconds: TimeInterval) -> Vector {
        return movement.estimatedVelocity(after: seconds)
    }
}

protocol EntityWithTargetableSystemInGame: EntityWithGame where GameType: GameWithTargetableSystem {
    
}

protocol GameWithTargetableSystem: GameWithUpdatableSystem {
    var targetableSystem: TargetableSystem<Self> { get }
}

private struct Target: Comparable {
    init(withEntity entity: TargetableEntity) {
        position = entity.position
        distanceToDestination = entity.distanceToDestination
        self.entity = entity
    }
    let position: Vector
    let distanceToDestination: Scalar
    let entity: TargetableEntity
}

private func ==(leftTarget: Target, rightTarget: Target) -> Bool {
    return leftTarget.distanceToDestination == rightTarget.distanceToDestination
}

private func <(leftTarget: Target, rightTarget: Target) -> Bool {
    return leftTarget.distanceToDestination < rightTarget.distanceToDestination
}

public typealias CustomIsTargetFunction = (_ targetPosition: Vector, _ towerPosition: Vector, _ maxDistanceSquared: Double) -> Bool

final class TargetableSystem<GameType: GameWithUpdatableSystem>: BasicSystemWithGame<GameType>, EntityWithUpdatableComponents, UpdatableComponent {
    
    var updatableComponents: [(UpdateStep, (TimeInterval) -> ())] = []
    
    // playground support
    var customIsTargetFunction: CustomIsTargetFunction?
    
    fileprivate var targetableEntitites: Array<TargetableEntity> = []
    
    override func initComponents() {
        super.initComponents()
        addUpdatableComponent(updatable)
    }
    
    override func addEntity(_ entity: Entity) {
        guard let entity = entity as? TargetableEntity else {
            return
        }
        targetableEntitites.append(entity)
    }
    
    override func removeEntity(_ entity: Entity) {
        guard let entity = entity as? TargetableEntity else {
            return
        }
        if let index = targetableEntitites.index(where: { $0 === entity }) {
            targetableEntitites.remove(at: index)
        }
    }
    /**
     targets cache
    */
    fileprivate var _targets: [Target]?
    
    /**
     all targets, sorted by the distance to their destination, the closest first
     */
    fileprivate var targets: [Target] {
        if _targets == nil {
            _targets = targetableEntitites
                .filter{ $0.isTargetable }
                .map { return Target(withEntity: $0) }
                .sorted(by: <)
        }
        return _targets!
    }
    
    func isTargetInRange(targetPosition: Vector, towerPosition: Vector, maxDistanceSquared: Scalar) -> Bool {
        if let customIsTargetFunction = customIsTargetFunction {
            return customIsTargetFunction(targetPosition, towerPosition, maxDistanceSquared)
        }
        return targetPosition.distanceSquaredTo(towerPosition) <= maxDistanceSquared
    }
    /**
     tries to get a target in range, if it find multiple targets, it will return which is closest to their destination
    */
    @available(*, deprecated)
    func getTarget(fromPosition position: Vector, inRange maxDistance: Scalar) -> TargetableEntity? {
        
        return targets.first {
            return isTargetInRange(targetPosition: $0.position, towerPosition: position, maxDistanceSquared: maxDistance * maxDistance)
        }?.entity
    }
    /**
     tries to get a target in range, if it find multiple targets, it will return which is closest to their destination
     */
    func getTarget(fromPosition position: Vector, inRangeSquared maxDistanceSquared: Scalar) -> TargetableEntity? {
        
        return targets.first {
            return isTargetInRange(targetPosition: $0.position, towerPosition: position, maxDistanceSquared: maxDistanceSquared)
            }?.entity
    }
    /**
     get all targets in range, sorted by the distance to their destination, the closest first
     */
    @available(*, deprecated)
    func getAllTargets(fromPosition position: Vector, inRange maxDistance: Scalar) -> [TargetableEntity] {
        return targets.filter { (target) -> Bool in
            return isTargetInRange(targetPosition: target.position, towerPosition: position, maxDistanceSquared: maxDistance * maxDistance)
        }.map {
            return $0.entity
        }
    }
    /**
     get all targets in range, sorted by the distance to their destination, the closest first
     */
    func getAllTargets(fromPosition position: Vector, inRangeSquared maxDistanceSquared: Scalar) -> [TargetableEntity] {
        return targets.filter { (target) -> Bool in
            return isTargetInRange(targetPosition: target.position, towerPosition: position, maxDistanceSquared: maxDistanceSquared)
            }.map {
                return $0.entity
        }
    }
    
    let updateStep = UpdateStep.willEvaluateInput
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        //clear cache
        _targets = nil
    }
}
