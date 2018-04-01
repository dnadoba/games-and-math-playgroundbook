//
//  FireballTower.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 27.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation


import SpriteKit

final class FireballTower<GameType: GameWithTimerSystem & GameWithNodeSystem & GameWithTargetableSystem & GameWithInteractionSystem>: Tower<GameType>, GunComponentDelegate, StateEffectSource {
    
    fileprivate let gun: GunComponent<GameType, FireballTower<GameType>> = {
        $0.fireRate = 1.5
        $0.range = 300
        $0.offset = Vector(0, 50)
        return $0
    }(GunComponent<GameType, FireballTower<GameType>>())
    
    override func initComponents() {
        super.initComponents()
        
        gun.initComponent(withEntity: self)
        gun.delegate = self

        texture = SKTexture(imageNamed: "FireballTower")
        size = Size(92, 134)
    }
    
    func shot(atEntity target: TargetableEntity, fromPosition startPosition: Vector) {
        let bullet = Fireball<GameType>(fromSource: self)
        bullet.position = startPosition
        bullet.target = target
        game?.addEntityWithGame(bullet)
    }
}
