//
//  Enemy.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

protocol EnemyDelegate: class {
    func enemyDidDie()
    func enemyDidReachEnd()
}

final class Enemy<GameType: GameWithNodeSystem & GameWithTimerSystem>: BasicEntityWithGame<GameType>, EntityWithMovement, EntityWithAnimator, TargetableEntity, MoveAlongPathDelegate, EntityWithStateEffectManagerComponent, EffectableEntity, StateEffectManagerDelegate, EntityWithTimers {
    
    var timers: [TimerModel] = []
    
    weak var delegate: EnemyDelegate?
    
    var speed = Scalar() {
        didSet {
            movement.speed = speed
        }
    }
    
    let health = HealthAttributeComponent<Enemy<GameType>>()
    let healthBar = HealthBarComponent<Enemy<GameType>>()
    var effectManager = StateEffectManagerComponent<GameType, Enemy<GameType>>()
    
    var shape = ShapeComponent.circle(12)
    
    let movement = MoveAlongPathComponent<Enemy<GameType>>()
    
    var isTargetable: Bool {
        return health.isAlive
    }
    
    var distanceToDestination: Scalar {
        return movement.distanceToDestination
    }
    
    let movementAnimationTexture: UniversalTexture = {
        $0.gameSize = Size(32*9, 32*4)
        return $0
    }(UniversalTexture(imageNamed: "Zombie1MovementAnimation"))
    
    let dyingAnimationTexture: UniversalTexture = {
        $0.gameSize = Size(32*6, 32*1)
        return $0
    }(UniversalTexture(imageNamed: "Zombie1DyingAnimation"))
    
    let animator = AnimatorComponent<Enemy<GameType>>()
    let movementAnimator = MovementAnimatorComponent<Enemy<GameType>>()
    
    lazy var movementAnimationSequenes: [MovementDirection: UniversalAnimationSequence] = {
        let basis = UniversalAnimationSequence(
            withTexture: self.movementAnimationTexture,
            andSize: Size(32, 32),
            frameCount: 7,
            frameDuration: (15/32) / 7,
            looping: true,
            atOrigin: Vector(32, 0)
        )
        return [
            MovementDirection.top: basis.sequence(atIndex: 3, withDuration: 15/32),
            MovementDirection.left: basis.sequence(atIndex: 2, withDuration: 20/32),
            MovementDirection.bottom: basis.sequence(atIndex: 1, withDuration: 15/32),
            MovementDirection.right: basis.sequence(atIndex: 0, withDuration: 20/32),
        ]
    }()
    
    lazy var dyingAnimationSequence: UniversalAnimationSequence = {
        return UniversalAnimationSequence(withTexture: self.dyingAnimationTexture, andSize: Size(32, 32), frameCount: 6, frameDuration: 0.8/6, looping: false)
    }()
    
    
    lazy var burningEffectEmitter: UniversalEmitter = {
        $0.particleBirthRate = 0
        $0.zPosition = 10000
        self.addChild($0)
        return $0
    }(UniversalEmitter.fromFileNamed("burns")!)
    
    init(withPrototype prototype: EnemyPrototype) {
        super.init()
        applyPrototype(prototype)
    }
    
    func applyPrototype(_ prototype: EnemyPrototype) {
        self.health.reset(withHitPoints: prototype.hitpoints)
        self.speed = prototype.speed
    }
    
    override func initComponents() {
        super.initComponents()
        
        rootNode.zIndexOffset = 100
        
        //animatedSprite.initComponent(withEntity: self)
        health.initComponent(withEntity: self)
        healthBar.initComponent(withEntity: self)
        healthBar.offset = Vector(0, 26)
        effectManager.initComponent(withEntity: self)
        effectManager.delegate = self
        movement.initComponent(withEntity: self)
        movement.delegate = self
        
        animator.initComponent(withEntity: self)
        animator.zPosition = 100
        animator.offset.y = 8
        movementAnimator.initComponent(withEntity: self)
        movementAnimator.animationSequences = movementAnimationSequenes
        
        animator.sprite.gameSize = Size(54, 54)
    }
    
    func didDie(withLastHitFromSource source: Entity) {
        movement.stop()
        movementAnimator.pause()
        animator.playbackSpeed = 1
        animator.play(dyingAnimationSequence, startAtFrame: 0)
        let fadeOutAnimation = SKAction.sequence([
            SKAction.wait(forDuration: dyingAnimationSequence.completeDuration),
            SKAction.fadeOut(withDuration: 0.4),
            
        ])
        
        let playDieSound = SKAction.playSoundFileNamed("Zombie1DieSound", waitForCompletion: true)
        
        let remove = SKAction.run({
            self.removeFromGame()
        })
        
        animator.sprite.run(SKAction.sequence([
                SKAction.group([
                        playDieSound,
                        fadeOutAnimation,
                    ]),
                remove,
            ]))
        delegate?.enemyDidDie()
    }
    func didTakeDamage(_ amount: Scalar, fromSource: Entity) {
        //highlight entity
    }
    
    func didReachEnd() {
        delegate?.enemyDidReachEnd()
        removeFromGame()
    }
    func addVisualEffect(_ effect: VisualStateEffect) {
        switch effect {
        case VisualStateEffect.Throttle:
            animator.sprite.color = UIColor.blue
            animator.sprite.colorBlendFactor = 0.25
        case VisualStateEffect.Fire:
            burningEffectEmitter.particleBirthRate = burningEffectEmitter.inital.particleBirthRate
        default:
            break
        }
    }
    func removeVisualEffect(_ effect: VisualStateEffect) {
        switch effect {
        case VisualStateEffect.Throttle:
            animator.sprite.colorBlendFactor = 0
        case VisualStateEffect.Fire:
            burningEffectEmitter.particleBirthRate = 0
        default:
            break
        }
    }
    
}
