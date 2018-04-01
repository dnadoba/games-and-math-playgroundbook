//
//  SoundSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 29.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

protocol GameWithSoundSystem: GameWithNodeSystem {
    var soundSystem: SoundSystem<Self> { get }
}

final class SoundSystem<GameType: GameWithNodeSystem>: BasicSystemWithGame<GameType> {
    
    func playSound(fileNamed soundFile: String) {
        let playSound = SKAction.playSoundFileNamed(soundFile, waitForCompletion: false)
        game?.nodeSystem.scene.run(playSound)
    }
}
