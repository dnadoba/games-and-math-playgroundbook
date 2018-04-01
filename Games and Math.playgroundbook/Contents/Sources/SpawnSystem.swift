//
//  SpawnSystem.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 28.06.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

protocol GameWithSpawnSystem: GameWithEnemyPrototypeList, GameWithTargetableSystem, GameWithEnemyManager {
    var spawnSystem: SpawnSystem<Self> { get }
}

struct SpawnState: State {
    static fileprivate let startState = SpawnState(isSpawning: false, hasWaveLeft: true)
    let isSpawning: Bool
    let hasWaveLeft: Bool
    var canStartNextWave: Bool {
        return !isSpawning && hasWaveLeft
    }
}

func ==(lhs: SpawnState, rhs: SpawnState) -> Bool {
    return lhs.isSpawning == rhs.isSpawning &&
        lhs.hasWaveLeft == rhs.hasWaveLeft
}


final class SpawnSystem<GameType: GameWithTimerSystem & GameWithEnemyPrototypeList & GameWithTargetableSystem & GameWithNodeSystem & GameWithEnemyManager>: BasicSystemWithGame<GameType>, EnemySpawnQueueDelegate, StateMachine {
    
    var currentState = SpawnState.startState
    
    let didChangeState = WeakEvent<StateChangeEvent<SpawnState>>()
    
    fileprivate(set) var spawnPoints: [SpawnPoint<GameType>] = []
    
    override func addEntity(_ entity: Entity) {
        guard let spawnPoint = entity as? SpawnPoint<GameType> else {
            return
        }
        spawnPoints.append(spawnPoint)
        spawnPoint.spawnQueue.delegate = self
    }
    
    override func removeEntity(_ entity: Entity) {
        guard let spawnPoint = entity as? SpawnPoint<GameType> else {
            return
        }
        spawnPoints.remove(spawnPoint)
        spawnPoint.spawnQueue.delegate = nil
    }
    
    func startNextWave() {
        guard currentState.canStartNextWave else {
            return
        }
        for spawnPoint in spawnPoints {
            spawnPoint.waveQueue.startNextWave()
        }
        updateSpawnStateIfNeeded()
    }
    
    fileprivate func computeCurrentState() -> SpawnState {
        let isSpawning = spawnPoints.reduce(false) { (isSpawning, spawnPoint) in
            return isSpawning || spawnPoint.spawnQueue.isSpawning
        }
        
        let hasWaveLeft = spawnPoints.reduce(false) { (hasWaveLeft, spawnPoint) in
            return hasWaveLeft || spawnPoint.waveQueue.hasWaveLeft
        }
        
        return SpawnState(isSpawning: isSpawning, hasWaveLeft: hasWaveLeft)
    }
    
    func didFinishSpawning() {
        updateSpawnStateIfNeeded()
    }
    
    fileprivate func updateSpawnStateIfNeeded() {
        updateToStateIfNeeded(computeCurrentState())
    }
}
