//
//  BackgroundEffect.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class BackgroundEffect<GameType: GameWithNodeSystem>: BasicEntityWithGame<GameType>, EntityWithLayoutableComponents {
    
    var layoutableComponents: [LayoutableComponent] = []
    
    let emitter = BackgroundEmitterComponent<BackgroundEffect<GameType>>()
    
    override func initComponents() {
        super.initComponents()
        emitter.initComponent(withEntity: self)
    }
}