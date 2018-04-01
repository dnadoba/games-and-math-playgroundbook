//
//  SpawnComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 25.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol EntityWithEnemySpawnQueue: EntityWithGame, EntityWithPosition, EntityWithUpdatableComponents where GameType: GameWithEnemyPrototypeList, GameType: GameWithTargetableSystem, GameType: GameWithEnemyManager {
    
    var spawnQueue: EnemySpawnQueueComponent<GameType, Self> { get }
}

protocol EnemySpawnQueueDelegate {
    func didFinishSpawning()
}

final class EnemySpawnQueueComponent<GameType: GameWithEnemyPrototypeList & GameWithNodeSystem & GameWithTargetableSystem & GameWithTimerSystem & GameWithEnemyManager, EntityType: EntityWithGame & EntityWithPosition & EntityWithUpdatableComponents>: BasicComponentWithGame<GameType, EntityType>, UpdatableComponent where EntityType.GameType == GameType {
    
    var ways: [Way] = []
    
    var isSpawning: Bool {
        return !squadQueue.isEmpty || !spawnQueue.isEmpty
    }
    
    var delegate: EnemySpawnQueueDelegate?
    
    fileprivate var previousSpawnedEnemy: EnemyPrototype?
    fileprivate var squadQueue: [EntitySpawnSquad] = []
    fileprivate var spawnQueue: [EntitySpawnInfo] = []
    fileprivate var timeSinceLastSpawn: TimeInterval = 0
    
    override func initComponent(withEntity entity: EntityType) {
        super.initComponent(withEntity: entity)
        
        entity.addUpdatableComponent(updatable)
    }
    
    let updateStep = UpdateStep.update
    
    var updatable: (UpdateStep, (TimeInterval) -> ()) {
        return (updateStep, updateWithDeltaTime)
    }
    func updateWithDeltaTime(_ seconds: TimeInterval) {
        
        guard squadQueue.count > 0 || spawnQueue.count > 0 else {
            return
        }
        
        timeSinceLastSpawn += seconds
        
        if spawnQueue.count == 0 {
            let nextSquad = squadQueue.first!
            let waitDuration = nextSquad.startDelay.waitDuration(previousSpawnedEnemy?.speed)
            if timeSinceLastSpawn > waitDuration {
                spawnQueue = nextSquad.spawnInfos
                timeSinceLastSpawn -= waitDuration
                squadQueue.removeFirst()
            } else {
                return
            }
        }
        
        while spawnQueue.count > 0 {
            
            let nextSpawn = spawnQueue.first!
                
            let speedOfPreviosEnemy = previousSpawnedEnemy?.speed
            let waitDuration = nextSpawn.spawnDelay.waitDuration(speedOfPreviosEnemy)
                
            if timeSinceLastSpawn >= waitDuration {
                timeSinceLastSpawn -= waitDuration
                let prototype = prototypeForSpawnInfo(nextSpawn)
                let way = wayForSpawnInfo(nextSpawn)
                    
                    
                spawnEnemy(prototype, onWay: way)
                spawnQueue.removeFirst()
                    
                previousSpawnedEnemy = prototype
            } else {
                break
            }
            
        }
        
        if spawnQueue.count == 0 && squadQueue.count == 0 {
            delegate?.didFinishSpawning()
        }
    }
    
    fileprivate func wayForSpawnInfo(_ spawnInfo: EntitySpawnInfo) -> Way {
        return ways[spawnInfo.wayIndex]
    }
    
    fileprivate func prototypeForSpawnInfo(_ spawnInfo: EntitySpawnInfo) -> EnemyPrototype {
        return game!.enemyPrototypeList[spawnInfo.prototype]
    }
    
    func spawnEnemy(_ prototype: EnemyPrototype, onWay way: Way) {
        let enemy: Enemy<GameType> = Enemy<GameType>(withPrototype: prototype)
        enemy.movement.moveAlongWay(way)
        
        game?.enemyManager.add(enemy)
    }
    
    func add(_ spawnInfo: EntitySpawnSquad) {
        squadQueue.append(spawnInfo)
    }
    
    func add(_ spawnInfos: [EntitySpawnSquad]) {
        squadQueue += spawnInfos
    }
}
