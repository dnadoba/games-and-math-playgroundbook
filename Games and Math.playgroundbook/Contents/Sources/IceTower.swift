//
//  IceTower.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class IceTower<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem>: Tower<GameType>, FlamethrowerDelegate, StateEffectSource {
    
    let flamethrower = FlamethrowerComponent<GameType, IceTower<GameType>>(emitterFileNamed: "iceflame")
    
    let effectOnTarget = StateEffect.throttle(ThrottleStateEffect(8, duration: 2))
    
    override func initComponents() {
        super.initComponents()
        
        flamethrower.initComponent(withEntity: self)
        flamethrower.offset = Vector(0, 60)
        flamethrower.delegate = self
        
        texture = SKTexture(imageNamed: "IceTower")
        size = Size(156, 153)
        
        addChild(flamethrower.flameEmitter)
    }
    
    func applyAffect(toTarget target: TargetableEntity) {
        target.apply(stateEffect: effectOnTarget, fromSource: self)
    }
}
