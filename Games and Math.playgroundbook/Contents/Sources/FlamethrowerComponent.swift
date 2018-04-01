//
//  FlamethrowerComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import simd
import SpriteKit

protocol FlamethrowerDelegate: class {
    func applyAffect(toTarget target: TargetableEntity)
}

final class FlamethrowerComponent<GameType: GameWithTargetableSystem, EntityType: EntityWithGame & EntityWithPosition & EntityWithUpdatableComponents & EntityWithRootNode>: BasicComponentWithGame<GameType, EntityType>, UpdatableComponent where EntityType.GameType == GameType {
    
    var debug = false {
        didSet {
            updateDebugShapes()
        }
    }
    
    /**
     radius around the entity in which entities can be targeted
     */
    var range: Scalar {
        get { return sqrt(rangeSquared) }
        set { rangeSquared = newValue * newValue }
    }
    var rangeSquared = pow(Scalar(180), 2) {
        didSet {
            updateEmitterEmissionRange()
            updateDebugShapes()
        }
    }
    
    var flameEmitterRangeOffset = Scalar(20) {
        didSet {
            updateEmitterEmissionRange()
        }
    }
    
    /**
     offset of the flamethrower component. used to determine if an entity is in range and is used for the start position of the flame
     */
    var offset = Vector(){
        didSet{
            flameEmitter.position = CGPoint(offset)
            updateDebugShapes()
        }
    }
    /**
        angle of the flame in radian
     */
    var flameAngle = Radian(40.degreesToRadians) {
        didSet {
            halfFlameAngle = flameAngle/2
            updateEmitterAngleRange()
            updateDebugShapes()
        }
    }
    fileprivate var halfFlameAngle = Radian(20.degreesToRadians)
    
    var flameEmitterAngleOffset = Radian(4.degreesToRadians) {
        didSet {
            updateEmitterAngleRange()
        }
    }
    
    
    
    weak var delegate: FlamethrowerDelegate?
    
    let flameEmitter: UniversalEmitter
    
    fileprivate var emitterBaseBirthRate: Scalar {
        return Scalar(flameEmitter.inital.particleBirthRate)
    }
    fileprivate var emitterBaseVelocity: Scalar {
        return Scalar(flameEmitter.inital.particleSpeed)
    }
    fileprivate var emitterBaseLifetime: Scalar {
        return Scalar(flameEmitter.inital.particleLifetime)
    }
    
    fileprivate lazy var emitterBaseRange: Scalar = { [unowned self] in
        //s(t) = v*t
        return self.emitterBaseVelocity * self.emitterBaseLifetime
        
    }()
    
    fileprivate var emitterBirthRate: Scalar {
        return range/emitterBaseRange * emitterBaseBirthRate
    }
    
    fileprivate var position: Vector {
        return entity.position + offset
    }
    /**
        normalized direction in which the component is looking
     */
    fileprivate var direction = Vector(1, 0)
    
    override init(){
        flameEmitter = UniversalEmitter.fromFileNamed("flame")!
        super.init()
    }
    
    init(emitterFileNamed: String){
        flameEmitter = UniversalEmitter.fromFileNamed(emitterFileNamed)!
        super.init()
    }
    
    init(withEmitterNode: UniversalEmitter) {
        flameEmitter = withEmitterNode
        super.init()
    }
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    
        flameEmitter.zPosition = 2000
        updateEmitterEmissionRange()
        updateEmitterAngleRange()
        updateDebugShapes()
    }
    
    fileprivate func updateEmitterEmissionRange(){
        // s(t) = v*t
        // t = const
        // v = s/t
        let range = self.range + flameEmitterRangeOffset
        flameEmitter.particleSpeed = CGFloat(range/emitterBaseLifetime)
    }
    
    fileprivate func updateEmitterAngleRange() {
        flameEmitter.emissionAngleRange = CGFloat(flameAngle + flameEmitterAngleOffset)
    }
    
    fileprivate func stopEmitting() {
        flameEmitter.particleBirthRate = 0
    }
    
    fileprivate func startEmitting() {
        flameEmitter.particleBirthRate = CGFloat(emitterBirthRate)
    }
    
    let updateStep = UpdateStep.didSimulatePhysics
    
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        guard let targets = game?.targetableSystem.getAllTargets(fromPosition: position, inRangeSquared: rangeSquared),
            targets.count > 0 else {
                
            stopEmitting()
            return
        }
        
        let mainTarget = targets.first!
        
        let targetPosition = mainTarget.position
        let estimatedTargetPosition = mainTarget.estimatedPosition(after: emitterBaseLifetime)
        aim(at: targetPosition)
        look(at: estimatedTargetPosition)
        
        startEmitting()
        
        if let delegate = delegate {
            //we are looking directly at the main target
            delegate.applyAffect(toTarget: mainTarget)
            targets[1..<targets.count].filter {
                isFacing(toTarget: $0.position)
            }.forEach(delegate.applyAffect)
        }
    }
    
    fileprivate func aim(at targetPosition: Vector) {
        direction = position.directionTo(targetPosition).normalized
        updateDebugShapes()
    }
    
    fileprivate func look(at estimatedTargetPosition: Vector) {
        
        let angle = position.directionTo(estimatedTargetPosition).angle
        
        flameEmitter.emissionAngle = CGFloat(angle)
        updateDebugShapes()
    }
    
    fileprivate func isFacing(toTarget target: Vector) -> Bool {
        
        let directionToTarget = position.directionTo(target).normalized
        let angle = acos(direction.dot(directionToTarget))
        return abs(angle) < halfFlameAngle
    }
    
    var debugShapeForRadius: SKShapeNode?
    var debugLastRange = Scalar(0)
    
    var debugShapeForAngle: SKShapeNode?
    var debugLastEmissionAngle = CGFloat(0)
    
    fileprivate func updateDebugShapes() {
        guard debug else {
            return
        }
        if debugLastRange != range || debugShapeForRadius == nil{
            debugLastRange = range
            debugShapeForRadius?.removeFromParent()
            debugShapeForRadius = SKShapeNode(circleOfRadius: CGFloat(range))
            entity.addChild(debugShapeForRadius!)
        }
        
        debugShapeForRadius!.position = CGPoint(offset)
        
        if flameEmitter.emissionAngle != debugLastEmissionAngle || debugShapeForAngle == nil {
            debugLastEmissionAngle = flameEmitter.emissionAngle
            debugShapeForAngle?.removeFromParent()
            let angle = direction.angle
            let points = [
                Vector(range, 0).rotate(angle + flameAngle/2),
                Vector(0, 0),
                Vector(range, 0).rotate(angle - flameAngle/2),
            ]
        
            debugShapeForAngle = SKShapeNode(path: points)
            entity.addChild(debugShapeForAngle!)
        }
        debugShapeForAngle!.position = CGPoint(offset)
    }
}
