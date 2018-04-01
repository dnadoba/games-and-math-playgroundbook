//
//  BackgroundColorLoader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 16.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class BackgroundColorLoader<GameType: GameWithGameScene>: LevelLoader {
    unowned var game: GameType
    init(game: GameType) {
        self.game = game
    }
    func loadLevel(_ sceneModel: SKNode, withName: String) -> Bool{
        guard let scene = sceneModel as? SKScene else {
            return false
        }
        
        game.scene.backgroundColor = scene.backgroundColor
        return true
    }
}
