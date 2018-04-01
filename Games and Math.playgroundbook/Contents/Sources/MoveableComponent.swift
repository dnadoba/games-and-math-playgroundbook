//
//  MoveableComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol EntityWithMovement: EntityWithPosition {
    associatedtype MovementType: MoveableComponent
    var movement: MovementType { get }
}

protocol MoveableComponent: ComponentWithEntity {
    /**
     normal movement speed in units per second
     */
    var speed: Scalar { get set }
    
    /**
     speed reduction in units per seconds
     */
    var throttle: Scalar { get set }
    /**
     actual speed in unites per seconds
     */
    var currentSpeed: Scalar { get }
    /**
     direction of the movement, must be normalized
     */
    var direction: Vector { get set }
    /**
     movement velocity in units per second
     */
    var velocity: Vector { get }
    
    func estimatedPosition(after seconds: TimeInterval) -> Vector
    func estimatedVelocity(after seconds: TimeInterval) -> Vector
}