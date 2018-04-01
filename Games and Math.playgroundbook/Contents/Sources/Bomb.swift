//
//  Bomb.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class Bomb<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithSoundSystem>: BasicEntityWithGame<GameType>, EntityWithAcceleratedMovement, SlingshotComponentDelegate, EntityWithTimers {
    var timers: [TimerModel] = []
    
    let effectSource: StateEffectSource
    let effectOnTarget = StateEffect.damage(DamageStateEffect(150))
    var explosionRadius: Scalar {
        get { return sqrt(explosionRadiusSquared) }
        set { return explosionRadiusSquared = newValue * newValue }
    }
    var explosionRadiusSquared = pow(Scalar(80), 2)
    fileprivate let sprite = SKSpriteNode(imageNamed: "Bomb")
    let movement = AcceleratedMovementComponent<Bomb<GameType>>()
    let slingshot = SlingshotComponent<GameType, Bomb<GameType>>()

    init(fromSource source: StateEffectSource) {
        effectSource = source
        super.init()
    }
    
    override func initComponents() {
        super.initComponents()
        
        rootNode.zIndexOffset = 2000
        
        movement.initComponent(withEntity: self)
        slingshot.initComponent(withEntity: self)
        slingshot.delegate = self
        
        
        addChild(sprite)
        sprite.position.y = sprite.size.height/2
    }
    
    func aim(atTarget target: TargetableEntity, fromPosition startPosition: Vector) {
        self.position = startPosition
        self.slingshot.aim(fromPosition: startPosition, toTarget: target)
    }
    
    func didReachTarget(atDestinationPosition destinationPosition: Vector) {
        
        let smokeEffect = SKEmitterNode(fileNamed: "BombSmoke")!
        smokeEffect.position = CGPoint(destinationPosition)
        smokeEffect.zPosition = 4000
        
        smokeEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: Foundation.TimeInterval(smokeEffect.particleLifetime)),
            SKAction.removeFromParent(),
            ]))
        
        addNodeToScene(smokeEffect, on: .gameplay, relatedToEntity: false)
        
        let expolsionEffect = SKEmitterNode(fileNamed: "BombExpolsion")!
        expolsionEffect.position = CGPoint(destinationPosition)
        expolsionEffect.zPosition = 6000
        
        expolsionEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: Foundation.TimeInterval(expolsionEffect.particleLifetime)),
            SKAction.removeFromParent(),
        ]))
        addNodeToScene(expolsionEffect, on: .gameplay, relatedToEntity: false)
        
        game?.soundSystem.playSound(fileNamed: "BombExplosion")
        
        
        game?.targetableSystem.getAllTargets(fromPosition: destinationPosition, inRangeSquared: explosionRadiusSquared).forEach {
            $0.apply(stateEffect: effectOnTarget, fromSource: effectSource)
        }
        
        removeFromGame()
    }
}
