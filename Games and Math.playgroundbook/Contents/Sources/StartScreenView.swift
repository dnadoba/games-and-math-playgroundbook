//
//  StartScreenView.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import UIKit
import SpriteKit

final class StartScreenView: BasicGameController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let game = EffectGame()
        if !game.loadLevel("StartScreen") {
            print("loading start screen has failed")
        }
        
        self.game = game
        
        if let skView = self.view as? GameView {
            skView.presentGame(game)
            
            
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            
            skView.ignoresSiblingOrder = true
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func back(_ segue:UIStoryboardSegue) {
        print("back")
    }
}
