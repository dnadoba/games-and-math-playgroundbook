//
//  FireTower.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class FireTower<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem>: Tower<GameType>, StateEffectSource, FlamethrowerDelegate {
    
    
    let flamethrower = FlamethrowerComponent<GameType, FireTower<GameType>>()
    let effectOnTarget = StateEffect.fire(FireStateEffect(25, duration: 2))
    
    override func initComponents() {
        super.initComponents()
        
        flamethrower.initComponent(withEntity: self)
        flamethrower.offset = Vector(0, 60)
        flamethrower.delegate = self
        
        texture = SKTexture(imageNamed: "FireTower")
        size = Size(156, 153)
        
        rootNode.addChild(flamethrower.flameEmitter)
    }
    
    func applyAffect(toTarget target: TargetableEntity) {
        target.apply(stateEffect: effectOnTarget, fromSource: self)
    }
}
