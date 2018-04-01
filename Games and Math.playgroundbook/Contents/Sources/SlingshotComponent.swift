//
//  AimComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 28.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol SlingshotComponentDelegate: class {
    func didReachTarget(atDestinationPosition destinationPosition: Vector)
}

final class SlingshotComponent<GameType: GameWithTimerSystem, EntityType: EntityWithGame & EntityWithAcceleratedMovement & EntityWithTimers>: BasicComponentWithGame<GameType, EntityType> where EntityType.GameType == GameType {
    
    var duration = Scalar(1.3)
    
    fileprivate let gravity = Scalar(-10*60)
    
    weak var delegate: SlingshotComponentDelegate?
    
    func aim(fromPosition startPosition: Vector, toTarget target: TargetableEntity) {
        let destinationPosition = target.estimatedPosition(after: duration)
        let direction = startPosition.directionTo(destinationPosition)
        
        entity.movement.apply(Vector(
            //v = s/t
            direction.x / duration,
            //v = s - g/2*t
            (direction.y - 0.5 * gravity * (duration*duration))/duration
        ))
        entity.movement.acceleration = Vector(0, gravity)
        
        entity.schedule(timer: .timeout(duration)) { [unowned self] in
            self.delegate?.didReachTarget(atDestinationPosition: destinationPosition)
        }
    }
}
