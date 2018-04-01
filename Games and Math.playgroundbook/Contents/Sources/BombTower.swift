//
//  BombTower.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class BombTower<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem & GameWithSoundSystem>: Tower<GameType>, GunComponentDelegate, StateEffectSource {
    
    fileprivate let gun: GunComponent<GameType, BombTower<GameType>> = {
        $0.fireRate = 2.5
        $0.range = 260
        $0.offset = Vector(0, 40)
        return $0
    }(GunComponent<GameType, BombTower<GameType>>())
    
    override func initComponents() {
        super.initComponents()
        
        gun.initComponent(withEntity: self)
        gun.delegate = self
        
        texture = SKTexture(imageNamed: "BombTower")
        size = Size(140, 126)
    }
    func shot(atEntity target: TargetableEntity, fromPosition startPosition: Vector) {
        let bullet = Bomb<GameType>(fromSource: self)
        bullet.aim(atTarget: target, fromPosition: startPosition)
        
        
        game?.addEntityWithGame(bullet)
    }
}
