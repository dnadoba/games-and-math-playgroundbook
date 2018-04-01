//
//  GameView.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 24.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

class GameView: SKView {
    func presentGame(_ game: GameWithGameScene) {
        self.presentScene(game.scene)
    }
    func presentGame(_ game: GameWithGameScene, transition: SKTransition) {
        self.presentScene(game.scene, transition: transition)
    }
    
   
    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return self.scene?.preferredFocusEnvironments ?? super.preferredFocusEnvironments
    }
    #endif

}
