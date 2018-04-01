//
//  BackgroundEffectLoader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

private let emitterSuffix = "Background"

final class BackgroundEffectLoader<GameType: GameWithNodeSystem>: LevelLoader {
    
    
    unowned var game: GameType
    
    init(game: GameType) {
        self.game = game
    }
    func loadLevel(_ sceneModel: SKNode, withName levelName: String) -> Bool {
        let emitterFileName = levelName + emitterSuffix
        guard let emitterNode = UniversalEmitter.fromFileNamed(emitterFileName) else {
            fatalError("Can't load BackgroundEffect emitter with name \(emitterFileName) for level \(levelName)")
        }
        
        let backgroundEffect = BackgroundEffect<GameType>()
        backgroundEffect.emitter.node = emitterNode
        game.addEntityWithGame(backgroundEffect)
        
        return true
    }
}
