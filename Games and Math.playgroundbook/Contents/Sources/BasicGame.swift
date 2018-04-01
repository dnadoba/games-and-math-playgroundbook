//
//  BasicGame.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 18.05.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

class BasicGame: NSObject, Game, GameWithContentSizeManager, GameWithContentInsetManager, GameWithUpdatableSystem, GameWithNodeSystem, GameWithTimerSystem, GameSceneDelegate, SKSceneDelegate{
    var entities: [Entity] = []
    var systems: [System] = []
    var levelLoaders: Array<LoadLevelClosure> = []
    
    var currentTime: TimeInterval = 0
    
    let timerSystem = TimerSystem()
    let updatableSystem = UpdatableSystem()
    let nodeSystem = NodeSystem()
    let layoutSystem = LayoutSystem<BasicGame>()
    
    let camera = Camera<BasicGame>()
    let contentSizeManager = ContentSizeManager()
    let contentInsetManager = ContentInsetManager()
    
    var speed: Scalar {
        get { return updatableSystem.speed }
        set { updatableSystem.speed = newValue }
    }
    
    override init() {
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
        
        addEntityWithGame(camera)
        nodeSystem.scene.camera = camera.cameraNode
        
        addEntityWithoutGame(contentSizeManager)
    }
    func initLevelLoaders() {}
    func didMoveToView(_ view: SKView) {
        #if os(iOS) || os(tvOS)
        view.insertSubview(camera.scrollView.scrollView, at: 0)
        #endif
    }
    func willMoveFromView(_ view: SKView) {
        #if os(iOS) || os(tvOS)
        camera.scrollView.scrollView.removeFromSuperview()
        #endif
    }
    
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

