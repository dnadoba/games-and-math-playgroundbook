//
//  EffectGame
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

final class EffectGame: BasicGame, GameWithFireworkSystem {
    let fireworkSystem = FireworkSystem<EffectGame>()
    
    override func initSystems() {
        super.initSystems()
        addSystemWithGame(fireworkSystem)
    }
    
    override func initLevelLoaders() {
        super.initLevelLoaders()
        
        self.addLevelLoader(BackgroundEffectLoader(game: self))
    }
    
    override func didLoadLevel() {
        super.didLoadLevel()
        makeFirework()
        
    }
    
    func makeFirework() {
        makeFirework(at: Vector(0.3, 0.4), after: 0, with: #colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1))
        makeFirework(at: Vector(0.5, 0.6), after: 0.8, with: #colorLiteral(red: 0.4028071761, green: 0.7315050364, blue: 0.2071235478, alpha: 1), size: 300)
        makeFirework(at: Vector(0.7, 0.5), after: 0.4, with: #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1))
        
        makeFirework(at: Vector(0.75, 0.75), after: 0.2, with: #colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1))
        makeFirework(at: Vector(0.25, 0.75), after: 0.6, with: #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1))
    }
    
    func makeFirework(at relativePosition: Vector, after timeout: TimeInterval, with color: SKColor, size: Scalar = 400) {
        timerSystem.schedule(timer: .timeout(timeout), on: self) { [unowned self] in
            let firework = Firework<EffectGame>(repeating: true, repeatDelay: 1)
            firework.relative.position = relativePosition
            firework.relative.scale = RelativeScale.toViewSizeMinWithNormalSize(of: size)
            firework.setMainColor(color)
            self.addEntityWithGame(firework)
        }
    }
}
