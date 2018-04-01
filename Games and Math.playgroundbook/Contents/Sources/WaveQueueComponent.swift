//
//  WaveManagerComponent.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 28.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

final class WaveQueueComponent<EntityType: EntityWithEnemySpawnQueue>: BasicComponent<EntityType> {
    var waves: [WavePrototype] = []
    
    var hasWaveLeft: Bool {
        return !waves.isEmpty
    }
    
    func startNextWave() {
        guard !waves.isEmpty else {
            return
        }
        
        let nextWave = waves.removeFirst()
        
        entity.spawnQueue.add(nextWave.squads)
    }
}