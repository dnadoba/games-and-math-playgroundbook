//
//  MovementAnimationComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd
import SpriteKit



struct AnimationSpriteSequence {
    let origin: Vector
    let size: Size
    let direction: Vector
    let count: Int
    let completeCycleDistance: Scalar
    
    func offset(atFrame frame: Int) -> Vector {
        let offset = size * direction * Scalar(frame % count)
        return origin + offset
    }
    func rect(atFrame frame: Int) -> CGRect{
        let position = offset(atFrame: frame)
        return CGRect(origin: CGPoint(position), size: CGSize(size))
    }
}

final class MovementAnimationComponent<EntityType: EntityWithMovement & EntityWithUpdatableComponents>: BasicComponent<EntityType>, UpdatableComponent {
    
    fileprivate var movedDistance = Scalar(0)
    
    let sprite = UniversalSprite()
    
    var texture: UniversalTexture?
    var animationSpriteSequence: [MovementDirection: AnimationSpriteSequence]?
    
    var direction: MovementDirection = .top {
        didSet {
            if oldValue != direction {
                didChangeDirection()
            }
        }
    }
    
    fileprivate var lastFrame: Int = 0
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.didSimulatePhysics
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        let oldDirection = direction
        direction = MovementDirection(fromDirection: entity.movement.direction)
        guard let texture = texture,
            let animationSpriteSequence = animationSpriteSequence?[direction] else {
            return
        }
        
        let frame = Int(round((movedDistance/animationSpriteSequence.completeCycleDistance) * Scalar(animationSpriteSequence.count)))
        
        movedDistance += entity.movement.speed * seconds
        
        if oldDirection != direction || frame != lastFrame {
            lastFrame = frame
            let rect = animationSpriteSequence.rect(atFrame: frame)
            
            sprite.gameSize = animationSpriteSequence.size
            sprite.texture = texture.textureInRect(rect)
        }
    }
    
    fileprivate func didChangeDirection() {
        movedDistance = Scalar(0)
    }
}
