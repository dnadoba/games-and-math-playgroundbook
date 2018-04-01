//
//  Spawn.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 17.02.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

final class SpawnPoint<GameType: GameWithTimerSystem & GameWithEnemyPrototypeList & GameWithTargetableSystem & GameWithNodeSystem & GameWithEnemyManager>: BasicEntityWithGame<GameType>, EntityWithEnemySpawnQueue {
    
    let name: String
    
    let spawnQueue = EnemySpawnQueueComponent<GameType, SpawnPoint<GameType>>()
    let waveQueue = WaveQueueComponent<SpawnPoint<GameType>>()
    
    init(named name: String) {
        self.name = name
    }
    
    override func initComponents() {
        super.initComponents()
        
        spawnQueue.initComponent(withEntity: self)
        waveQueue.initComponent(withEntity: self)
    }
}
