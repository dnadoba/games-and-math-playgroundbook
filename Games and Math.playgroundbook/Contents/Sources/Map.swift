//
//  Map.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class Map<GameType: GameWithNodeSystem>: BasicEntityWithGame<GameType> {
    
    var sprite: SKSpriteNode? {
        didSet {
            oldValue?.removeFromParent()
            guard let sprite = sprite else {
                return
            }
            addChild(sprite)
        }
    }
    
    override func initComponents() {
        super.initComponents()
        
        rootNode.zIndexOffset = -10000
    }
}