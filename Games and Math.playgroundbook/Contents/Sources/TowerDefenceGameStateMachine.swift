//
//  TowerDefenceGameStateMachine.swift
//  EntityComponentSystem
//
//  Created by David Jonas Nadoba on 31.07.16.
//  Copyright © 2016 David Nadoba. All rights reserved.
//

import Foundation

enum TowerDefenceGameState: State {
    case playing
    case won
    case lost
}

private extension SpawnState {
    var hasFinished: Bool {
        return !isSpawning && !hasWaveLeft
    }
}

final class TowerDefenceGameStateMachine<GameType: GameWithNodeSystem & GameWithSpawnSystem & GameWithLifeManager>: BasicEntityWithGame<GameType>, StateMachine, ExternalStateObserver {
    
    var currentState = TowerDefenceGameState.playing
    let didChangeState = WeakEvent<StateChangeEvent<TowerDefenceGameState>>()
    
    override func added(to game: GameType) {
        super.added(to: game)
        
        game.lifeManager.addStateObserver(self)
        game.spawnSystem.addStateObserver(self)
        game.enemyManager.addStateObserver(self)
    }
    override func removed(from game: GameType) {
        super.removed(from: game)
        
        game.lifeManager.removeStateObserver(self)
        game.spawnSystem.removeStateObserver(self)
        game.enemyManager.removeStateObserver(self)
    }
    
    fileprivate func computeCurrentState() -> TowerDefenceGameState{
        guard let game = game else {
            return TowerDefenceGameState.playing
        }
        if !game.lifeManager.currentState.isAlive {
            return TowerDefenceGameState.lost
        }
        
        if game.spawnSystem.currentState.hasFinished &&
            game.enemyManager.currentState.alive <= 0 {
            return TowerDefenceGameState.won
        }
        return TowerDefenceGameState.playing
    }
    
    func externalStateHasChanged() {
        updateStateIfNeeded()
    }
    
    fileprivate func updateStateIfNeeded() {
        updateToStateIfNeeded(computeCurrentState())
    }
}
