//
//  Game.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 02.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation
import SpriteKit

typealias LoadLevelClosure = (_ sceneModel: SKNode, _ withName: String) -> Bool

protocol Game: class {
    var entities: Array<Entity> { get set }
    var systems: Array<System> { get set }
    var levelLoaders: Array<LoadLevelClosure> { get set }
    
    func initSystems()
    func initEntities()
    func initLevelLoaders()
    
    func levelFileName(_ levelName: String) -> String
    func loadLevel(_ levelName: String) -> Bool
    
    func didLoadLevel()
    
    var paused: Bool { get }
    func pause()
    func resume()
}

extension Game {
    func initGame() {
        initSystems()
        initEntities()
        initLevelLoaders()
    }
    private func addSystem(_ system: System) {
        systems.append(system)
    }
    
    func addSystemWithoutGame(_ system: System) {
        addSystem(system)
    }
    /*
        function decleartion would be better with
        func addSystemWithGame<SystemType: SystemWithGame where SystemType.GameType == Self>(system: SystemType)
        but it crashes the compiler in release build
        (1. While emitting IR SIL function)
     */
    func addSystemWithGame<SystemType: SystemWithGame>(_ system: SystemType) where SystemType.GameType == Self {
        system.game = self
        addSystem(system)
    }
    
    private func addEntity(_ entity: Entity) {
        entities.append(entity)
        
        for system in systems {
            system.addEntity(entity)
        }
    }
    func addEntityWithoutGame(_ entity: Entity) {
        addEntity(entity)
    }
    
    func addEntityWithGame<EntityType: EntityWithGame>(_ entity: EntityType) where EntityType.GameType == Self {
        entity.game = self
        addEntity(entity)
        entity.added(to: self)
    }
    
    private func removeEntity(_ entity: Entity) {
        for system in systems {
            system.removeEntity(entity)
        }
        
        if let index = entities.index(where: { $0 === entity }) {
            entities.remove(at: index)
        }

    }
    
    func removeEntityWithGame<EntityType: EntityWithGame>(_ entity: EntityType) where EntityType.GameType == Self {
        removeEntity(entity)
        entity.game = nil
        entity.removed(from: self)
    }
    
    func addLevelLoader<LevelLoaderType: LevelLoader>(_ levelLoader: LevelLoaderType) {
        levelLoaders.append(levelLoader.loadLevel)
    }
    
    func loadLevel(_ levelName: String) -> Bool {
        let fileName = levelFileName(levelName)
        guard let levelScene = SKScene(fileNamed: fileName) else {
            return false
        }
        
        for levelLoader in levelLoaders {
            if !levelLoader(levelScene, levelName) {
                return false
            }
        }
        
        didLoadLevel()
        
        return true
    }
}

extension Game {
    func entities<EntityType: EntityWithGame>(of type: EntityType.Type) -> [EntityType] {
        return entities.flatMap { return $0 as? EntityType }
    }
}
