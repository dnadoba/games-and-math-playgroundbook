//
//  MovementAnimatorComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 20.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

let twoPi = Scalar.pi * 2

enum MovementDirection: Int {
    static let directionCount = Scalar(4)
    case right = 0, top, left, bottom
    init(fromDirection direction: Vector) {
        self.init(rotation: atan2(direction.y, direction.x))
    }
    init(rotation: Scalar) {
        let rotation = (rotation + twoPi).truncatingRemainder(dividingBy: twoPi)
        
        let orientation = rotation / twoPi
        
        let rawFacingValue = round(orientation * MovementDirection.directionCount).truncatingRemainder(dividingBy: MovementDirection.directionCount)
        self.init(rawValue: Int(rawFacingValue))!
    }
}

final class MovementAnimatorComponent<EntityType: EntityWithAnimator & EntityWithMovement & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent {
    
    fileprivate(set) var paused: Bool = false
    var animationSequences: [MovementDirection: UniversalAnimationSequence] = [:]
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    
    let updateStep = UpdateStep.didSimulatePhysics
    
    fileprivate var lastDirection: MovementDirection?
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        guard !paused else {
            return
        }
        
        adjustAnimationPlaybackSpeed()
        let direction = MovementDirection(fromDirection: entity.movement.direction)
        
        //check if the direction has changed
        guard direction != lastDirection else {
            return
        }
        
        //check if we have a animation for the current movement
        guard let animationSequence = animationSequences[direction] else {
            return
        }
        //now change the animation direction
        lastDirection = direction
        
        entity.animator.play(animationSequence, startAtFrame: 0)
        
    }
    
    fileprivate func adjustAnimationPlaybackSpeed() {
        entity.animator.playbackSpeed = entity.movement.speed / entity.movement.currentSpeed
    }
    
    func resume() {
        paused = false
    }
    
    func pause() {
        paused = true
    }
}
