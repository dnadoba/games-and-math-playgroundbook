//
//  MapLoader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class MapLoader<GameType: GameWithNodeSystem>: LevelLoader {
    unowned var game: GameType
    init(game: GameType) {
        self.game = game
    }
    func loadLevel(_ sceneModel: SKNode, withName: String) -> Bool{
        guard let mapSprite = sceneModel.childNode(withName: "Map") as? SKSpriteNode else {
            return false
        }
        
        let map = Map<GameType>()
        map.sprite = mapSprite.copy() as? SKSpriteNode
        
        game.addEntityWithGame(map)
        
        return true
    }
}
