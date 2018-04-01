//
//  Fireball.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 24.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class Fireball<GameType: GameWithTimerSystem & GameWithNodeSystem>: BasicEntityWithGame<GameType>, EntityWithMovement, CollidableEntity, CollisionDelegate, EntityWithTimers {
    
    var timers: [TimerModel] = []
    
    let effectSource: StateEffectSource
    
    let effectOnTarget = StateEffect.damage(DamageStateEffect(100))
    
    let shape = ShapeComponent.circle(10)
    
    weak var target: TargetableEntity? {
        didSet {
            followTarget.target = target
            collision.target = target
        }
    }
    
    fileprivate let emitter = SKEmitterNode(fileNamed: "Fireball")!
    
    fileprivate let followTarget = FollowTargetComponent<Fireball<GameType>>()
    fileprivate let collision = CollisionComponent<Fireball<GameType>>()
    
    let movement = LinearMovementComponent<Fireball<GameType>>()
    
    required init(fromSource source: StateEffectSource) {
        effectSource = source
        super.init()
    }
    
    override func initComponents() {
        super.initComponents()
        rootNode.zIndexOffset = 2024
        addChild(emitter)
        
        movement.initComponent(withEntity: self)
        movement.speed = 280
        followTarget.initComponent(withEntity: self)
        collision.initComponent(withEntity: self)
        collision.delegate = self
    }
    
    func didCollide(withTarget entity: CollidableEntity) {
        //apply damage
        target?.apply(stateEffect: effectOnTarget, fromSource: effectSource)
        
        //stop the bullet
        target = nil
        movement.direction = Vector()
        
        //stop emitter to create particles
        emitter.particleBirthRate = 0
        
        //remove the bullet after all particle are gone
        let delay = Scalar(emitter.particleLifetime + emitter.particleLifetimeRange)
        schedule(timer: .timeout(delay)) { [unowned self] in
            self.removeFromGame()
        }
        
        
        
    }
}
