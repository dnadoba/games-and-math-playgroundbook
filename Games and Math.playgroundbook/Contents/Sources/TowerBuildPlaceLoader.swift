//
//  TowerBuildPlaceLoader.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit


final class TowerBuildPlaceLoader<GameType: GameWithSpawnPoints & GameWithUpdatableSystem & GameWithMoneyManager & GameWithInteractionSystem & GameWithSoundSystem>: LevelLoader {
    unowned var game: GameType
    init(game: GameType) {
        self.game = game
    }
    func loadLevel(_ sceneModel: SKNode, withName: String) -> Bool {
        
        
        guard let towerBuildPlaceNodes = sceneModel.childNode(withName: "towers")?.children else {
            return false
        }
        
        let towerBuildPlaces = towerBuildPlaceNodes.map { node -> TowerBuildPlace<GameType> in
            let position = Vector(node.position)
            let towerBuildPlace = TowerBuildPlace<GameType>()
            towerBuildPlace.position = position
            return towerBuildPlace
        }
        
        for entity in towerBuildPlaces {
            game.addEntityWithGame(entity)
        }
        
        return true
    }
}
