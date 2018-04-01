//
//  BasicSpriteKitGame.swift
//  EntityComponentSystem
//
//  Created by David Nadoba on 11.01.17.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

class BasicSpriteKitGame: NSObject, Game, GameWithUpdatableSystem, GameWithNodeSystem, GameWithTimerSystem, GameWithContentSizeManager, GameSceneDelegate, SKSceneDelegate{
    var entities: [Entity] = []
    var systems: [System] = []
    var levelLoaders: Array<LoadLevelClosure> = []
    
    var currentTime: TimeInterval = 0
    
    let timerSystem = TimerSystem()
    let updatableSystem = UpdatableSystem()
    let nodeSystem: NodeSystem
    let layoutSystem = LayoutSystem<BasicSpriteKitGame>()
    
    let contentSizeManager = ContentSizeManager()
    
    var speed: Scalar {
        get { return updatableSystem.speed }
        set { updatableSystem.speed = newValue }
    }
    
    override init() {
        nodeSystem = NodeSystem()
        super.init()
        initGame()
    }
    
    init(scene: GameScene) {
        nodeSystem = NodeSystem(scene: scene)
        super.init()
        initGame()
    }
    
    func initSystems() {
        addSystemWithoutGame(timerSystem)
        addSystemWithoutGame(updatableSystem)
        addSystemWithoutGame(nodeSystem)
        addSystemWithGame(layoutSystem)
        
        
        scene.delegate = self
        scene.gameDelegate = self
    }
    func initEntities() {
        systems.forEach(addEntityWithoutGame)
        
        addEntityWithoutGame(contentSizeManager)
    }
    func initLevelLoaders() {
        self.addLevelLoader(ContentSizeLoader(game: self))
    }
    func didMoveToView(_ view: SKView) {}
    func willMoveFromView(_ view: SKView) {}
    
    func didChangeSize(_ oldSize: Size) {
        layoutSystem.didChangeSize(nodeSystem.size, oldViewSize: oldSize)
    }
    func levelFileName(_ levelName: String) -> String { return levelName }
    func didLoadLevel() {}
    
    @objc func update(_ currentTime: TimeInterval, for scene: SKScene){
        let system = updatableSystem
        
        system.startUpdateLoop(currentTime)
        scene.speed = CGFloat(system.currentSpeed)
        
        system.update(.willEvaluateInput)
        system.update(.evaluateInput)
        system.update(.didEvaluateInput)
        system.update(.update)
        system.update(.willSimulatePhysics)
        system.update(.simulatePhysics)
        system.update(.didSimulatePhysics)
        system.update(.executeTimer)
        system.update(.willRenderScene)
    }
}
