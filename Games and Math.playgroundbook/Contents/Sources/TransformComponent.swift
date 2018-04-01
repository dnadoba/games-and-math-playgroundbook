//
//  TransformComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 10.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

/**
 Position Vector
*/
typealias PositionComponent = Vector

protocol EntityWithPosition: Entity {
    var position: PositionComponent {get set}
}


/** 
 Rotation around z-axis
*/
typealias RotationComponent = Scalar

protocol EntityWithRotation: Entity {
    var rotation: RotationComponent { get set }
}


/**
 Scale Vector
*/
typealias ScaleComponent = Vector

protocol EntityWithScale: Entity {
    var scale: ScaleComponent { get set }
}


/**
 Entity with Position, Rotation and Scale
*/
protocol TransformableEntity: EntityWithPosition, EntityWithRotation, EntityWithScale {}

