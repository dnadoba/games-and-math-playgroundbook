//
//  Firework.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit
import simd



final class Firework<GameType: GameWithNodeSystem & GameWithTimerSystem>: BasicEntityWithGame<GameType>, EntityWithTimers, RelativeTransformableEntity, EntityWithLayoutableComponents {
    
    var timers: [TimerModel] = []
    
    var layoutableComponents: [LayoutableComponent] = []
    
    let relative = RelativeTransformComponent<Firework>()
    
    let repeating: Bool
    
    let repeatDelay: TimeInterval
    
    fileprivate let fireworkEmitter = SKEmitterNode(fileNamed: "Firework")!
    
    fileprivate let mainColorIndexs = [2, 3]
    
    init(repeating: Bool, repeatDelay: TimeInterval = 0) {
        self.repeating = repeating
        self.repeatDelay = repeatDelay
    }
    
    override func initComponents() {
        super.initComponents()
        rootNode.layer = .screen
        
        relative.initComponent(withEntity: self)

        addChild(fireworkEmitter)
        
        let effectDuration = TimeInterval(fireworkEmitter.particleLifetime)
        
        let interval = effectDuration + repeatDelay
        if repeating {
            schedule(timer: .interval(interval)) { [unowned self] in
                self.reset()
            }
        }
    }
    
    func reset() {
        fireworkEmitter.resetSimulation()
    }
    
    func setMainColor(_ color: SKColor) {
        let sequence = fireworkEmitter.particleColorSequence!
        
        for index in mainColorIndexs {
            sequence.setKeyframeValue(color, for: index)
        }
        
        fireworkEmitter.particleColorSequence = sequence
    }
    
    func setFireworkFieldBitMask(_ bitMask: UInt32) {
        fireworkEmitter.fieldBitMask = bitMask
    }
}
